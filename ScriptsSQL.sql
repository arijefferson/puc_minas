-- TableDataLake
CREATE TABLE [dbo].[DL_HistoricoInteracoes]
(
    [CPF] [numeric] NOT NULL,
    [PF_SITUACAO] [nvarchar](8) NOT NULL,
	[PF_SITUACAO_RFB] [nvarchar](8) NOT NULL,
    [PF_DT_NASCIMENTO] [smalldatetime] NOT NULL,
	[PF_GENERO] [nvarchar](10) NOT NULL,
	[PF_UF] [nvarchar](2) NOT NULL,
	[CNPJ] [numeric] NOT NULL,
	[PJ_SITUACAO] [nvarchar](8) NOT NULL,
	[PJ_SITUACAO_RFB] [nvarchar](8) NOT NULL,
	[PJ_PORTE] [nvarchar](12) NOT NULL,
	[PJ_SETOR] [nvarchar](10) NOT NULL,
	[PJ_DT_ABERTURA] [smalldatetime] NOT NULL,
	[PJ_NUM_FUNCIONARIOS] [int] NOT NULL,
	[PJ_UF] [nvarchar](2) NOT NULL,
	[CANAL_ATENDIMENTO] [nvarchar](50) NOT NULL,
	[TEMA_ATENDIMENTO] [nvarchar](50) NOT NULL,
	[ABORDAGEM_ATENDIMENTO] [nvarchar](10) NOT NULL,
	[CATEGORIA_ATENDIMENTO] [nvarchar](10) NOT NULL,
	[INSTRUMENTO_ATENDIMENTO] [nvarchar](20) NOT NULL,
	[MEIO_ATENDIMENTO] [nvarchar](30) NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN),
    CLUSTERED COLUMNSTORE INDEX
);

-- Select para Preparação de Importação
BEGIN
	DECLARE 
		@DT_INICIO AS DATETIME, 
		@DT_FIM AS DATETIME 
	SET @DT_INICIO = '2018-07-01 00:00:00.000'
	SET @DT_FIM = '2020-06-01 23:59:59.000'
	SELECT DISTINCT
			-- ATRIBUTOS CADASTRAIS PF
			PARPF.CgcCpf AS [CPF],
			IIF(PARPF.Situacao = 1 , 'Ativo' , 'Inativo') AS [PF_SITUACAO],
			IIF(PARPF.Situacao = 1 , 'Ativo' , 'Inativo') AS [PF_SITUACAO_RFB],
			--CONVERT(CHAR(10),PF.DataNasc,103) AS [PF_DT_NASCIMENTO],
			PF.DataNasc AS [PF_DT_NASCIMENTO],
			CASE PF.Sexo WHEN 1 THEN 'Masculino' WHEN 0 THEN 'Feminino' ELSE 'Não se aplica/Não declarado' END AS [PF_GENERO],
			ESTPF.AbrevEst AS [PF_UF],
			-- ATRIBUTOS CADASTRAIS PJ
			PARPJ.CgcCpf AS [CNPJ],
			IIF(PARPJ.Situacao = 1 , 'Ativo' , 'Inativo') AS [PJ_SITUACAO],
			CASE RFB.SIT_CADASTRAL
				WHEN '02' THEN 'Ativo'
				WHEN '04' THEN 'Ativo'
				ELSE 'Inativo'
			END AS [PJ_SITUACAO_RFB],
			CASE PORTE.porte
				WHEN 'MicroEmpreendedor Individual' THEN 'MEI'
				WHEN 'Microempresa' THEN 'ME'
				WHEN 'Empresa de Pequeno Porte' THEN 'EPP'
				WHEN 'Grande Empresa' THEN 'Grande Empresa'
				WHEN 'Média Empresa' THEN 'Média Empresa'
				ELSE 'Não declarado'
			END AS [PJ_PORTE],
			SETOR.DescSetor AS [PJ_SETOR],
			--CONVERT(CHAR(10),PJ.databert,103) AS [PJ_DT_ABERTURA],
			PJ.databert AS [PJ_DT_ABERTURA],
			PJ.NumFunc AS [PJ_NUM_FUNCIONARIOS],
			ESTPJ.AbrevEst AS [PJ_UF],
			-- TRANSACIONAIS PF/PJ
			CASE APL.aplicacaoDescricao
				WHEN 'AUTODIAG UAIT' THEN 'Aplicativo'
				WHEN 'EDUCAÇÃO' THEN 'Sistema de Atendimento Educativo'
				WHEN 'INTEGRAÇÃO SEBRAE/UF' THEN 'Sistema de Atendimento Online'
				WHEN 'PORTAL SEBRAE NACIONAL' THEN 'Autoatendimento'
				WHEN 'SEBRAETEC' THEN 'Aplicativo'
				WHEN 'SENHOR ORIENTADOR' THEN 'Sistema de Atendimento Presencial'
				WHEN 'SIACWEB PARCEIROS' THEN 'Sistema de Atendimento Governamental'
				WHEN 'SISNEG' THEN 'Sistema de Atendimento Presencial'
				WHEN 'SISTEMA ATENDIMENTO INTEGRADO' THEN 'Sistema de Atendimento Online'
				WHEN 'Sistema de Atendimento Sebrae - SAS' THEN 'Sistema de Atendimento Presencial'
				WHEN 'Sistema de Atendimento Sebrae - SAS (ALI)' THEN 'Sistema de Atendimento Presencial'
				WHEN 'Sistema de Atendimento Sebrae - SAS (Eventos)' THEN 'Sistema de Eventos'
				WHEN 'Sistema de Atendimento Sebrae - SAS (Webservice)' THEN 'Sistema de Atendimento Online'
				WHEN 'SISTEMA DE CONSULTORIA 2.0' THEN 'Sistema de Eventos'
				WHEN 'SISTEMA DE EDUCAÇÃO EMPREENDEDORA' THEN 'Sistema de Atendimento Educativo'
				WHEN 'SISTEMA DE INFORMAÇÃO' THEN 'Sistema de Atendimento Online'
				WHEN 'SISTEMA DE INFORMAÇÃO ANTIGO' THEN 'Sistema de Atendimento Presencial'
				WHEN 'SISTEMALI' THEN 'Sistema de Atendimento Presencial'
				WHEN 'WEBAULA' THEN 'Sistema EAD'
				WHEN 'WEBSERVICE' THEN 'Sistema de Atendimento Online'
				ELSE 'Aplicativo'
			END AS [CANAL_ATENDIMENTO],
			CASE ATM.DescAreaTematica 
				WHEN 'Legislação do MEI' THEN 'Legislação e Fiscalização' 
				WHEN 'Lei geral no município' THEN 'Legislação e Fiscalização'
				WHEN 'Leis' THEN 'Legislação e Fiscalização'
				WHEN 'Baixa de Empresa' THEN 'Legislação e Fiscalização'
				WHEN 'Simples' THEN 'Legislação e Fiscalização'
				WHEN 'Normas técnicas' THEN 'Legislação e Fiscalização'
				WHEN 'Impostos e tributação no SIMPLES' THEN 'Legislação e Fiscalização'
				WHEN 'Tributos' THEN 'Legislação e Fiscalização' 
				WHEN 'Beneficio Fiscal' THEN 'Legislação e Fiscalização'
				WHEN 'Fiscalização orientadora' THEN 'Legislação e Fiscalização'
				WHEN 'Certificação / Inspeção' THEN 'Certificações e Registros'
				WHEN 'Avaliação da conformidade/certificação' THEN 'Certificações e Registros'
				WHEN 'Registro de Marca' THEN 'Certificações e Registros'
				WHEN 'Registro e patentes' THEN 'Certificações e Registros'
				WHEN 'Registro e patentes' THEN 'Certificações e Registros'
				WHEN 'Registro de Empresa' THEN 'Certificações e Registros'
				WHEN 'Propriedade Intelectual' THEN 'Certificações e Registros'
				WHEN 'Convênio BB/Orientação para o Crédito' THEN 'Convênios'
				WHEN 'Convênio BB/Recuperação de Crédito' THEN 'Convênios'
				WHEN 'Cooperação e certificação' THEN 'Cooperação'
				WHEN 'Cooperação e inclusão social' THEN 'Cooperação'
				WHEN 'Cooperativa financeira' THEN 'Cooperação'
				WHEN 'Cooperativismo' THEN 'Cooperação'
				WHEN 'Cooperativismo de Crédito' THEN 'Cooperação'
				WHEN 'Cultura da cooperação' THEN 'Cooperação'
				WHEN 'Abertura e legalização de empresas' THEN 'Abertura de negócios'
				WHEN 'Design de ambiente' THEN 'Design'
				WHEN 'Design de comunicação' THEN 'Design'
				WHEN 'Design de produto' THEN 'Design'
				WHEN 'Design de serviço' THEN 'Design'
				WHEN 'Layout' THEN 'Design'
				WHEN 'Empreendimentos coletivos - sociedade de propósito específico' THEN 'Empreendedorismo'
				WHEN 'Comportamento empreendedor' THEN 'Empreendedorismo'
				WHEN 'Educação Empreendedora' THEN 'Empreendedorismo'
				WHEN 'Capital empreendedor' THEN 'Empreendedorismo'
				WHEN 'Central de negócios' THEN 'Empreendedorismo'
				WHEN 'Editais de inovação' THEN 'Inovação'
				WHEN 'Inovação Tecnológica' THEN 'Inovação'
				WHEN 'Tecnologia e Inovação' THEN 'Inovação'
				WHEN 'Tendências em inovação' THEN 'Inovação'
				WHEN 'Aceleração/incubação de empresas' THEN 'Inovação'
				WHEN 'Eficiência Energética' THEN 'Inovação'
				WHEN 'Projeto de Desenvolvimento Tecnológico e Inovação' THEN 'Inovação'
				WHEN 'Transformação Digital' THEN 'Inovação'
				WHEN 'Ideias e tendências de negócios' THEN 'Inovação'
				WHEN 'Automação do processo produtivo' THEN 'Inovação'
				WHEN 'Planejamento e controle da produção/indicadores' THEN 'Planejamento'
				WHEN 'Planejamento e gestão financeira' THEN 'Planejamento'
				WHEN 'Planejamento Empresarial' THEN 'Planejamento'
				WHEN 'Planejamento estratégico' THEN 'Planejamento'
				WHEN 'Planejamento estratégico de marketing' THEN 'Planejamento'
				WHEN 'Plano de ação estratégico' THEN 'Planejamento'
				WHEN 'Planejamento Tecnológico' THEN 'Planejamento'
				WHEN 'Administração estratégica' THEN 'Planejamento'
				WHEN 'Plano de negócio' THEN 'Planejamento'
				WHEN 'Visão organizacional sistêmica' THEN 'Planejamento'
				WHEN 'Métodos e técnicas de produção' THEN 'Planejamento'
				WHEN 'Desenvolvimento do Produto' THEN 'Planejamento'
				WHEN 'Estrutura Funcional. Organizacional e Física' THEN 'Planejamento'
				WHEN 'Estratégia empresarial' THEN 'Planejamento'
				WHEN 'Modelo de negócios' THEN 'Planejamento'
				WHEN 'Vendas (geral)' THEN 'Vendas'
				WHEN 'Feiras e eventos' THEN 'Eventos'
				WHEN 'Controles financeiros' THEN 'Finanças'
				WHEN 'Financiamento' THEN 'Finanças'
				WHEN 'Financiamento Coletivo/Crowdfunding' THEN 'Finanças'
				WHEN 'Reorganização Financeira' THEN 'Finanças'
				WHEN 'Microfinanças' THEN 'Finanças'
				WHEN 'Fluxo de Caixa' THEN 'Finanças'
				WHEN 'Calculo e Analise de Custos' THEN 'Finanças'
				WHEN 'Precificação' THEN 'Finanças'
				WHEN 'Preço' THEN 'Finanças'
				WHEN 'Formação de Preço de Venda' THEN 'Finanças'
				WHEN 'Gestão da inovação' THEN 'Gestão'
				WHEN 'Gestão da Qualidade' THEN 'Gestão'
				WHEN 'Gestão da Sustentabilidade' THEN 'Gestão'
				WHEN 'Gestão de estoques' THEN 'Gestão'
				WHEN 'Gestão estratégica de pessoas' THEN 'Gestão'
				WHEN 'Ferramentas de Gestão' THEN 'Gestão'
				WHEN 'Gestão Financeira' THEN 'Gestão'
				WHEN 'Métodos e Técnicas de Gestão' THEN 'Gestão'
				WHEN 'Mapeamento e Melhoria de Processos' THEN 'Gestão'
				WHEN 'Organização' THEN 'Gestão'
				WHEN 'Organização Empresarial' THEN 'Gestão'
				WHEN 'Orientação para o Crédito' THEN 'Crédito e Investimentos'
				WHEN 'Linhas de Crédito' THEN 'Crédito e Investimentos'
				WHEN 'Microcrédito' THEN 'Crédito e Investimentos'
				WHEN 'Sociedade garantidora de crédito' THEN 'Crédito e Investimentos'
				WHEN 'Sociedade de Garantias de Créditos' THEN 'Crédito e Investimentos'
				WHEN 'Fundo de Aval às Micro e Pequenas Empresas - FAMPE' THEN 'Crédito e Investimentos'
				WHEN 'Corporate venture' THEN 'Crédito e Investimentos'
				WHEN 'Investimento Angel' THEN 'Crédito e Investimentos'
				WHEN 'Fundos de Investimento' THEN 'Crédito e Investimentos'
				WHEN 'Empresa Simples de Crédito' THEN 'Crédito e Investimentos'
				WHEN 'Água, Ar e Solo' THEN 'Agricultura'
				WHEN 'Boas práticas de produção/boas práticas agrícolas' THEN 'Agricultura'
				WHEN 'Melhoria Genética e Biotecnologia' THEN 'Agricultura'
				WHEN 'Marketing (geral)' THEN 'Marketing'
				WHEN 'Publicidade e Propaganda' THEN 'Marketing'
				WHEN 'Renegociação de Dívidas' THEN 'Dívidas, Fechamento, Falência e Concordata'
				WHEN 'Resíduos' THEN 'Dívidas, Fechamento, Falência e Concordata'
				WHEN 'Falência e Concordata' THEN 'Dívidas, Fechamento, Falência e Concordata'
				WHEN 'Inadimplência e renegociação de dívidas' THEN 'Dívidas, Fechamento, Falência e Concordata'
				WHEN 'Alteração de Empresa' THEN 'Mudanças'
				WHEN 'Ponto comercial' THEN 'Rede e Expansão'
				WHEN 'Consórcio de empresas' THEN 'Rede e Expansão'
				WHEN 'Rede de empresas' THEN 'Rede e Expansão'
				WHEN 'Franquia' THEN 'Rede e Expansão'
				WHEN 'Viabilidade de Ponto Comercial' THEN 'Rede e Expansão'
				WHEN 'Indicadores de aprendizado e crescimento' THEN 'Rede e Expansão'
				WHEN 'Tecnologia da produção' THEN 'Tecnologia e Serviços Digitais'
				WHEN 'Tic' THEN 'Tecnologia e Serviços Digitais'
				WHEN 'Serviços Digitais' THEN 'Tecnologia e Serviços Digitais'
				WHEN 'Informação tecnológica' THEN 'Tecnologia e Serviços Digitais'
				WHEN 'Ecommerce' THEN 'Tecnologia e Serviços Digitais'
				WHEN 'Comércio eletrônico' THEN 'Tecnologia e Serviços Digitais'
				WHEN 'Relações trabalhistas e aspectos legais' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Relacionamentos com cliente - CRM' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Trabalho em equipe' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Treinamento e desenvolvimento de pessoas' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Recrutamento e Seleção' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Promoção' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Saúde e Segurança do Trabalho' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Saúde e segurança no trabalho' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Pessoas' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Motivação' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Conhecimento e competência' THEN 'Relacionamento e Gestão de Pessoas'
				WHEN 'Pesquisa de mercado' THEN 'Economia e Mercado'
				WHEN 'Inteligência de mercado' THEN 'Economia e Mercado'
				WHEN 'Economia colaborativa (compartilhada)' THEN 'Economia e Mercado'
				WHEN 'Viabilidade econômico financeira' THEN 'Economia e Mercado'
				WHEN 'Mercado (geral)' THEN 'Economia e Mercado'
				WHEN 'Mercado e vendas' THEN 'Economia e Mercado'
				WHEN 'Oportunidade de Negócio' THEN 'Economia e Mercado'
				WHEN 'Oscip' THEN 'Economia e Mercado'
				WHEN 'Estudo de Viabilidade Economico-Financeira' THEN 'Economia e Mercado'
				WHEN 'Arranjo produtivo local' THEN 'Economia e Mercado'
				WHEN 'Inteligência competitiva para micro e pequena empresa' THEN 'Economia e Mercado'
				WHEN 'Empresas com potencial de alto impacto' THEN 'Economia e Mercado'
				WHEN 'Pequenos negócios com potencial de alto impacto' THEN 'Economia e Mercado'
				WHEN 'Associativismo' THEN 'Economia e Mercado'
				WHEN 'Cadeia de Suprimentos' THEN 'Logística'
				WHEN 'Canal de distribuição' THEN 'Logística'
				WHEN 'Ciclo de Vida do Produto' THEN 'Logística'
				WHEN 'Compras corporativas - pública e privada' THEN 'Logística'
				WHEN 'Compras públicas e contratos' THEN 'Logística'
				WHEN 'Compras públicas e contratosc' THEN 'Logística'
				WHEN 'Distribuição - Logística' THEN 'Logística'
				WHEN 'Encadeamento produtivo' THEN 'Logística'
				WHEN 'Meios de pagamento' THEN 'Logística'
				WHEN 'Metrologia' THEN 'Logística'
				WHEN 'Produto' THEN 'Logística'
				WHEN 'Garantias' THEN 'Seguros'
				ELSE ATM.DescAreaTematica
			END AS [TEMA_ATENDIMENTO],
			IIF(HRC.Abordagem = 'I' , 'Individual' , 'Grupo') AS [ABORDAGEM_ATENDIMENTO],
			IIF(CA.Situacao = 'D' , 'Digital' , 'Presencial') AS [CATEGORIA_ATENDIMENTO],
			CASE HRC.Instrumento
				WHEN 'Consultoria a Distância' THEN 'Consultorias'
				WHEN 'Consultoria Presencial' THEN 'Consultorias'
				WHEN 'Curso Presencial' THEN 'Cursos'
				WHEN 'Cursos a Distância' THEN 'Cursos'
				WHEN 'Cursos Presenciais' THEN 'Cursos'
				WHEN 'Informação' THEN 'Informações Gerais'
				WHEN 'Informação a Distância' THEN 'Informações Gerais'
				WHEN 'Informação Presencial' THEN 'Informações Gerais'
				WHEN 'Informação Técnica a Distância' THEN 'Informações Gerais'
				WHEN 'Informação Técnica Presencial' THEN 'Informações Gerais'
				WHEN 'Informações' THEN 'Informações Gerais'
				WHEN 'Oficina a Distância' THEN 'Eventos'
				WHEN 'Orientação a Distância' THEN 'Orientações Técnicas'
				WHEN 'Orientação Presencial' THEN 'Orientações Técnicas'
				WHEN 'Orientação Técnica a Distância' THEN 'Orientações Técnicas'
				WHEN 'Orientação Técnica Presencial' THEN 'Orientações Técnicas'
				WHEN 'Palestra' THEN 'Eventos'
				WHEN 'Palestra a distância' THEN 'Eventos'
				WHEN 'Seminário' THEN 'Eventos'
				WHEN 'Seminário a Distância' THEN 'Eventos'
				ELSE 'Informações Gerais'
			END AS [INSTRUMENTO_ATENDIMENTO],
			MA.DescMeioAtendimento AS [MEIO_ATENDIMENTO]
	FROM
			HistoricoRealizacoesCliente AS HRC
			INNER JOIN Parceiro AS PARPF ON PARPF.CodParceiro = HRC.CodCliente
			INNER JOIN Parceiro AS PARPJ ON PARPJ.CodParceiro = HRC.CodEmpreedimento
			INNER JOIN PessoaF AS PF ON PF.CodParceiro = PARPF.CodParceiro
			INNER JOIN PessoaJ AS PJ ON PJ.CodParceiro = PARPJ.CodParceiro
			INNER JOIN Endereco AS EDRPF ON EDRPF.CodParceiro = PF.CodParceiro AND EDRPF.Principal = 1
			INNER JOIN Endereco AS EDRPJ ON EDRPJ.CodParceiro = PJ.CodParceiro AND EDRPF.Principal = 1
			INNER JOIN Estado AS ESTPF ON ESTPF.CodEst = EDRPF.CodEst
			INNER JOIN Estado AS ESTPJ ON ESTPJ.CodEst = EDRPF.CodEst
			INNER JOIN Porte AS PORTE ON PORTE.CodPorte = PJ.Faturam
			INNER JOIN Setor AS SETOR ON SETOR.CodSetor = PJ.CodSetor
			INNER JOIN Aplicacao AS APL ON APL.AplicacaoCodigo = HRC.CodAplicacao
			INNER JOIN AtendimentoIntegrado AS ATI ON ATI.CodAtendIntegrado = HRC.CodRealizacao AND ATI.CodSebrae = HRC.CodSebrae
			INNER JOIN AtendimentoIntegradoTema AS ATIT ON ATIT.CodAtendIntegrado = HRC.CodRealizacao AND ATIT.CodSebrae = HRC.CodSebrae
			INNER JOIN AreaTematica AS ATM ON ATM.CodAreaTematica = ATIT.CodTema 
			INNER JOIN CategoriaAtendimento AS CA ON CA.CodCategoria = HRC.CodCategoria
			INNER JOIN MeioAtendimento AS MA ON MA.CodMeioAtendimento = ATI.CodMeioAtendimento
			INNER JOIN [NASVCSRVSQL11].[DH1MVP_HUB].[dbo].[VW008_ACOMPANHAMENTO_INDICADORES_UGE] RFB ON PARPJ.CgcCpf = RFB.CNPJ
	WHERE
			HRC.DataHoraInicioRealizacao BETWEEN @DT_INICIO AND @DT_FIM
			AND HRC.Instrumento IN ('Consultoria a Distância','Consultoria Presencial','Curso Presencial','Cursos a Distância',
									'Cursos Presenciais','Informação','Informação a Distância','Informação Presencial','Informação Técnica a Distância',
									'Informação Técnica Presencial','Informações','Oficina','Oficina a Distância','Orientação a Distância',
									'Orientação Presencial','Orientação Técnica a Distância','Orientação Técnica Presencial','Palestra',
									'Palestra a distância','Seminário','Seminário a Distância')
			AND HRC.CodEmpreedimento IS NOT NULL AND HRC.CodCliente IS NOT NULL AND PARPF.CgcCpf IS NOT NULL AND PARPJ.CgcCpf IS NOT NULL
			AND PJ.NumFunc IS NOT NULL AND MA.DescMeioAtendimento IS NOT NULL AND PF.DataNasc IS NOT NULL AND PJ.databert IS NOT NULL 
END;


-- Select para Preparação de Importação (Enriquecimento)
BEGIN
	DECLARE 
		@DT_INICIO AS DATETIME, 
		@DT_FIM AS DATETIME 
	SET @DT_INICIO = '2018-07-01 00:00:00.000'
	SET @DT_FIM = '2020-06-01 23:59:59.000'
	SELECT DISTINCT
			-- ATRIBUTOS CADASTRAIS PF
			PARPF.CgcCpf AS [CPF],
			IIF(PARPF.Situacao = 1 , 'Ativo' , 'Inativo') AS [PF_SITUACAO],
			IIF(PARPF.SituacaoRFB = 1 , 'Ativo' , 'Inativo') AS [PF_SITUACAO_RFB],
			CONVERT(CHAR(10),PF.DataNasc,103) + ' ' + CONVERT(VARCHAR(5),PF.DataNasc,108) AS [PF_DT_NASCIMENTO],
			CASE PF.Sexo WHEN 1 THEN 'Masculino' WHEN 0 THEN 'Feminino' ELSE 'Não se aplica/Não declarado' END AS [PF_GENERO],
			ESTPF.AbrevEst AS [PF_UF],
			-- ATRIBUTOS CADASTRAIS PJ
			PARPJ.CgcCpf AS [CNPJ],
			IIF(PARPJ.Situacao = 1 , 'Ativo' , 'Inativo') AS [PJ_SITUACAO],
			IIF(PARPJ.SituacaoRFB = 1 , 'Ativo' , 'Inativo') AS [PJ_SITUACAO_RFB],
			CASE PORTE.porte
				WHEN 'MicroEmpreendedor Individual' THEN 'MEI'
				WHEN 'Microempresa' THEN 'ME'
				WHEN 'Empresa de Pequeno Porte' THEN 'EPP'
				WHEN 'Grande Empresa' THEN 'Grande Empresa'
				WHEN 'Média Empresa' THEN 'Média Empresa'
				ELSE 'Não declarado'
			END AS [PJ_PORTE],
			SETOR.DescSetor AS [PJ_SETOR],
			CONVERT(CHAR(10),PJ.databert,103) + ' ' + CONVERT(VARCHAR(5),PJ.databert,108) AS [PJ_DT_ABERTURA],
			PJ.NumFunc AS [PJ_NUM_FUNCIONARIOS],
			ESTPJ.AbrevEst AS [PJ_UF],
			-- TRANSACIONAIS PF/PJ
			APL.aplicacaoDescricao AS [CANAL_ATENDIMENTO],
			ATM.DescAreaTematica AS [TEMA_ATENDIMENTO],
			HRC.Abordagem AS [ABORDAGEM_ATENDIMENTO],
			IIF(CA.Situacao = 'D' , 'Digital' , 'Presencial') AS [CATEGORIA_ATENDIMENTO],
			HRC.Instrumento AS [INSTRUMENTO_ATENDIMENTO],
			MA.DescMeioAtendimento AS [MEIO_ATENDIMENTO]
	FROM
			HistoricoRealizacoesCliente AS HRC
			INNER JOIN Parceiro AS PARPF ON PARPF.CodParceiro = HRC.CodCliente
			INNER JOIN Parceiro AS PARPJ ON PARPJ.CodParceiro = HRC.CodEmpreedimento
			INNER JOIN PessoaF AS PF ON PF.CodParceiro = PARPF.CodParceiro
			INNER JOIN PessoaJ AS PJ ON PJ.CodParceiro = PARPJ.CodParceiro
			INNER JOIN Endereco AS EDRPF ON EDRPF.CodParceiro = PF.CodParceiro AND EDRPF.Principal = 1
			INNER JOIN Endereco AS EDRPJ ON EDRPJ.CodParceiro = PJ.CodParceiro AND EDRPF.Principal = 1
			INNER JOIN Estado AS ESTPF ON ESTPF.CodEst = EDRPF.CodEst
			INNER JOIN Estado AS ESTPJ ON ESTPJ.CodEst = EDRPF.CodEst
			INNER JOIN Porte AS PORTE ON PORTE.CodPorte = PJ.Faturam
			INNER JOIN Setor AS SETOR ON SETOR.CodSetor = PJ.CodSetor
			INNER JOIN Aplicacao AS APL ON APL.AplicacaoCodigo = HRC.CodAplicacao
			INNER JOIN AtendimentoIntegrado AS ATI ON ATI.CodAtendIntegrado = HRC.CodRealizacao
			INNER JOIN AtendimentoIntegradoTema AS ATIT ON ATIT.CodAtendIntegrado = HRC.CodRealizacao 
			INNER JOIN AreaTematica AS ATM ON ATM.CodAreaTematica = ATIT.CodTema 
			INNER JOIN CategoriaAtendimento AS CA ON CA.CodCategoria = HRC.CodCategoria
			INNER JOIN MeioAtendimento AS MA ON MA.CodMeioAtendimento = ATI.CodMeioAtendimento
	WHERE
			HRC.DataHoraInicioRealizacao BETWEEN @DT_INICIO AND @DT_FIM
			AND HRC.InstrumentoValido = 1
			AND PARPF.CgcCpf IS NOT NULL 
			AND PARPJ.CgcCpf IS NOT NULL
END;


-- Cursor e procedure para enquecimento das informações com RFB
CREATE PROCEDURE dbo.SituacaoRFB AS
	BEGIN
		DECLARE @CPF NUMERIC  
		DECLARE @PF_SITUACAO VARCHAR(10)     
		DECLARE @PF_SITUACAO_RFB VARCHAR(10)     
		DECLARE @CNPJ NUMERIC
		DECLARE @PJ_SITUACAO VARCHAR(10)     
		DECLARE @PJ_SITUACAO_RFB VARCHAR(10)     
		DECLARE @MSG_ERRO VARCHAR(3000)
	-- Declaração do Cursor
	DECLARE C_CURSOR CURSOR LOCAL FORWARD_ONLY READ_ONLY STATIC FOR
	SELECT
	  PARPF.CgcCpf AS [CPF],
	  IIF(PARPF.Situacao = 1 , 'Ativo' , 'Inativo') AS [PF_SITUACAO],
	  CASE RFB.Sit_Cadastral_CPF
		WHEN '01' THEN 'Ativo' -- Regular para RFB
		WHEN '02' THEN 'Ativo' -- Ativo, porém, com questões judiciais
		ELSE 'Inativo' -- as demais situações são consideradas inativas na RFB
	  END AS [PF_SITUACAO_RFB],
	  PARPJ.CgcCpf AS [CNPJ],
	  IIF(PARPJ.Situacao = 1 , 'Ativo' , 'Inativo') AS [PJ_SITUACAO],
	  CASE RFB.Sit_Cadastral_CNPJ
		WHEN '01' THEN 'Ativo' -- Regular para RFB
		WHEN '02' THEN 'Ativo' -- Ativo, porém, inapta temporariamente devido questões judiciais
		ELSE 'Inativo' -- as demais situações são consideradas inativas na RFB
	  END AS [PJ_SITUACAO_RFB],
	FROM
		[NASVCSRVSQL11].[SERPRO_HUB].[VW008_RFB] RFB
		INNER JOIN [NASVCSRVSQL11].[SERPRO_HUB].[VW010_RFB] SIT ON SIT.SK_SIT =  RFB.FK_SIT
		LEFT JOIN Parceiro AS PARPF ON PARPF.CgcCpf = RFB.Pf_Cpf
		LEFT JOIN [SQLServerBI].[DL_HistoricoInteracoes] AS DLPF ON DLPF.CPF = PARPF.CgcCpf
		LEFT JOIN Parceiro AS PARPJ ON PARPJ.CgcCpf = RFB.Pj_Cnpj
		LEFT JOIN [SQLServerBI].[DL_HistoricoInteracoes] AS DLPJ ON DLPJ.CNPJ = PARPJ.CgcCpf
	WHERE
		DLPF.CPF = PARPF.CgcCpf AND DLPJ.CNPJ = PARPJ.CgcCpf
	-- Início do Cursor
	OPEN C_CURSOR;
	-- Atualizando variável de controle 
	FETCH NEXT FROM C_CURSOR INTO @CPF, @PF_SITUACAO, @PF_SITUACAO_RFB, @CNPJ, @PJ_SITUACAO, @PJ_SITUACAO_RFB, @MSG_ERRO
	-- Loop para resgatar os registros
	WHILE @@FETCH_STATUS = 0
	BEGIN
	  BEGIN TRY
		BEGIN TRANSACTION
    	-- Campos diferentes - processa alteração
		IF ((@PF_SITUACAO <> @PF_SITUACAO_RFB)
		BEGIN
		  -- Atualiza situação no Data Lake
		  UPDATE [SQLServerBI].[DL_HistoricoInteracoes] SET PF_SITUACAO_RFB = @PF_SITUACAO_RFB WHERE CPF = @CPF;
		END
		IF ((@PJ_SITUACAO <> @PJ_SITUACAO_RFB)
		BEGIN
		  -- Atualiza situação no Data Lake
		  UPDATE [SQLServerBI].[DL_HistoricoInteracoes] SET PJ_SITUACAO_RFB = @PF_SITUACAO_RFB WHERE CNPJ = @CNPJ;  
		END
		-- Instanciando
		COMMIT TRANSACTION
	  END TRY
	  BEGIN CATCH
		-- Verifica se há uma transação ativa para reverter
		IF (XACT_STATE()) <> 0 
		BEGIN      
		  ROLLBACK TRANSACTION
		END  
		SET @MSG_ERRO = 'Erro: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' Linha: ' + CONVERT(VARCHAR, ERROR_LINE()) + ' Mensagem: ' + COALESCE(ERROR_MESSAGE(), '')
		INSERT INTO LOG
		  (
		   DataErro,
		   CPF,
		   CNPJ,
		   Contexto,
		   MensagemErro)
		VALUES
		  (
		   GETDATE(),
		   @CPF,
		   @CNPJ,
		   'Rotina de Atualização de Situação RFB - [SQLServerBI].[DL_HistoricoInteracoes]',
		   @MSG_ERRO
		  )
	  END CATCH
	  -- Recupera próximo registro
	  FETCH NEXT FROM C_CURSOR INTO @CPF, @PF_SITUACAO, @PF_SITUACAO_RFB, @CNPJ, @PJ_SITUACAO, @PJ_SITUACAO_RFB, @MSG_ERRO
	END -- Fim do Loop para resgatar os registros
 	CLOSE C_CURSOR
	DEALLOCATE C_CURSOR
 -- Fim da Procedure
 END
GO
	/*######## GRANT ########*/
	-- Concede permissão
	GRANT EXECUTE ON dbo.SituacaoRFB TO [SQLServerBI].[DL_HistoricoInteracoes]
	GO

-- Verificações
BEGIN
	SELECT 
		COUNT(*) AS [VOLUMETRIA_TOTAL],
		COUNT(PJ_NUM_FUNCIONARIOS) AS [VOLUMETRIA_ATRIBUTO],
		(COUNT(PJ_NUM_FUNCIONARIOS) / COUNT(*)) * 100 [%_PREENCHIMENTO_ATRIBUTO],
		MIN(PJ_NUM_FUNCIONARIOS) AS [ATRIBUTO_MINIMO],
		MAX(PJ_NUM_FUNCIONARIOS) AS [ATRIBUTO_MAXIMO],
		AVG(PJ_NUM_FUNCIONARIOS) AS [ATRIBUTO_MEDIA],
		(SELECT TOP (1) PJ_NUM_FUNCIONARIOS FROM DL_HistoricoInteracoes GROUP BY PJ_NUM_FUNCIONARIOS ORDER BY COUNT(PJ_NUM_FUNCIONARIOS) DESC) AS [ATRIBUTO_MODA],
		(SELECT(
				(SELECT MAX(PJ_NUM_FUNCIONARIOS) FROM (SELECT TOP 50 PERCENT PJ_NUM_FUNCIONARIOS FROM DL_HistoricoInteracoes ORDER BY PJ_NUM_FUNCIONARIOS) AS BottomHalf) 
				+ 
				(SELECT MIN(PJ_NUM_FUNCIONARIOS) FROM (SELECT TOP 50 PERCENT PJ_NUM_FUNCIONARIOS FROM DL_HistoricoInteracoes ORDER BY PJ_NUM_FUNCIONARIOS DESC) AS TopHalf)) 
				/ 2 
				) AS MEDIANA,
		STDEVP(PJ_NUM_FUNCIONARIOS) AS [ATRIBUTO_DESVIO_PADRAO]
	FROM
		DL_HistoricoInteracoes
END; 


-- Mais verificações
SELECT 
	CPF,
	PF_SITUACAO,
	PF_DT_NASCIMENTO,
	PF_GENERO,
	PF_UF,
	CNPJ,
	PJ_SITUACAO,
	PJ_PORTE,
	PJ_SETOR,
	PJ_DT_ABERTURA,
	PJ_NUM_FUNCIONARIOS,
	PJ_UF,
	CANAL_ATENDIMENTO,
	TEMA_ATENDIMENTO,
	ABORDAGEM_ATENDIMENTO,
	CATEGORIA_ATENDIMENTO,
	INSTRUMENTO_ATENDIMENTO,
	MEIO_ATENDIMENTO,
	COUNT(*) 
FROM 
	DL_HistoricoInteracoes
GROUP BY 
	CPF,
	PF_SITUACAO,
	PF_DT_NASCIMENTO,
	PF_GENERO,
	PF_UF,
	CNPJ,
	PJ_SITUACAO,
	PJ_PORTE,
	PJ_SETOR,
	PJ_DT_ABERTURA,
	PJ_NUM_FUNCIONARIOS,
	PJ_UF,
	CANAL_ATENDIMENTO,
	TEMA_ATENDIMENTO,
	ABORDAGEM_ATENDIMENTO,
	CATEGORIA_ATENDIMENTO,
	INSTRUMENTO_ATENDIMENTO,
	MEIO_ATENDIMENTO
HAVING 
	COUNT(*) > 1
ORDER BY
	CPF


-- Análise de duplicidades
WITH X AS   (SELECT CPF,PF_SITUACAO,PF_DT_NASCIMENTO,PF_GENERO,PF_UF,
					CNPJ,PJ_SITUACAO,PJ_PORTE,PJ_SETOR,PJ_DT_ABERTURA,PJ_NUM_FUNCIONARIOS,PJ_UF,
					CANAL_ATENDIMENTO,TEMA_ATENDIMENTO,ABORDAGEM_ATENDIMENTO,CATEGORIA_ATENDIMENTO,INSTRUMENTO_ATENDIMENTO,MEIO_ATENDIMENTO
			,RN = ROW_NUMBER()
            OVER(PARTITION BY 
					CPF,PF_SITUACAO,PF_DT_NASCIMENTO,PF_GENERO,PF_UF,
					CNPJ,PJ_SITUACAO,PJ_PORTE,PJ_SETOR,PJ_DT_ABERTURA,PJ_NUM_FUNCIONARIOS,PJ_UF,
					CANAL_ATENDIMENTO,TEMA_ATENDIMENTO,ABORDAGEM_ATENDIMENTO,CATEGORIA_ATENDIMENTO,INSTRUMENTO_ATENDIMENTO,MEIO_ATENDIMENTO
				 ORDER BY CPF)
            FROM DL_HistoricoInteracoes)
SELECT * FROM X 
-- DELETE FROM X
WHERE RN > 1

-- Análise após remoção de duplicidades
SELECT 
	CPF,
	PF_SITUACAO,
	PF_DT_NASCIMENTO,
	PF_GENERO,
	PF_UF,
	CNPJ,
	PJ_SITUACAO,
	PJ_PORTE,
	PJ_SETOR,
	PJ_DT_ABERTURA,
	PJ_NUM_FUNCIONARIOS,
	PJ_UF,
	CANAL_ATENDIMENTO,
	TEMA_ATENDIMENTO,
	ABORDAGEM_ATENDIMENTO,
	CATEGORIA_ATENDIMENTO,
	INSTRUMENTO_ATENDIMENTO,
	MEIO_ATENDIMENTO,
	COUNT(*) 
FROM 
	DL_HistoricoInteracoes
GROUP BY 
	CPF,
	PF_SITUACAO,
	PF_DT_NASCIMENTO,
	PF_GENERO,
	PF_UF,
	CNPJ,
	PJ_SITUACAO,
	PJ_PORTE,
	PJ_SETOR,
	PJ_DT_ABERTURA,
	PJ_NUM_FUNCIONARIOS,
	PJ_UF,
	CANAL_ATENDIMENTO,
	TEMA_ATENDIMENTO,
	ABORDAGEM_ATENDIMENTO,
	CATEGORIA_ATENDIMENTO,
	INSTRUMENTO_ATENDIMENTO,
	MEIO_ATENDIMENTO
HAVING 
	COUNT(*) > 1
ORDER BY
	CPF


select count(*) from DL_HistoricoInteracoes
-- 2.446.094 (antes da alteração)

select distinct(PJ_PORTE), count(*) from DL_HistoricoInteracoes group by PJ_PORTE order by COUNT(*)
delete from DL_HistoricoInteracoes where PJ_PORTE IN ('Média Empresa','Não declarado','Grande Empresa') 
-- 4.226

select distinct(PJ_NUM_FUNCIONARIOS), count(*) from DL_HistoricoInteracoes group by PJ_NUM_FUNCIONARIOS order by COUNT(*)
delete from DL_HistoricoInteracoes where PJ_NUM_FUNCIONARIOS < 0
delete from DL_HistoricoInteracoes where PJ_NUM_FUNCIONARIOS > 100
-- 1
-- 1.903

-- Nova análise sobre duplicidades após novas condições
WITH X AS   (SELECT CPF,PF_SITUACAO,PF_DT_NASCIMENTO,PF_GENERO,PF_UF,
					CNPJ,PJ_SITUACAO,PJ_PORTE,PJ_SETOR,PJ_DT_ABERTURA,PJ_NUM_FUNCIONARIOS,PJ_UF,
					CANAL_ATENDIMENTO,TEMA_ATENDIMENTO,ABORDAGEM_ATENDIMENTO,CATEGORIA_ATENDIMENTO,INSTRUMENTO_ATENDIMENTO,MEIO_ATENDIMENTO
			,RN = ROW_NUMBER()
            OVER(PARTITION BY 
					CPF,PF_SITUACAO,PF_DT_NASCIMENTO,PF_GENERO,PF_UF,
					CNPJ,PJ_SITUACAO,PJ_PORTE,PJ_SETOR,PJ_DT_ABERTURA,PJ_NUM_FUNCIONARIOS,PJ_UF,
					CANAL_ATENDIMENTO,TEMA_ATENDIMENTO,ABORDAGEM_ATENDIMENTO,CATEGORIA_ATENDIMENTO,INSTRUMENTO_ATENDIMENTO,MEIO_ATENDIMENTO
				 ORDER BY CPF)
            FROM DL_HistoricoInteracoes)
DELETE FROM x WHERE RN > 1
-- 86.313


-- Verficações após análises de banco e via R
select count(*) from DL_HistoricoInteracoes
-- 2.439.964 (depois das alterações)


-- Complementos nas tasks do ETL (transformações para variáveis contínuas)
update DL_HistoricoInteracoes set PF_SITUACAO = 1 where PF_SITUACAO = 'Ativo'
update DL_HistoricoInteracoes set PF_SITUACAO = 0 where PF_SITUACAO = 'Inativo'
update DL_HistoricoInteracoes set PF_SITUACAO_RFB = 1 where PF_SITUACAO_RFB = 'Ativo'
update DL_HistoricoInteracoes set PF_SITUACAO_RFB = 0 where PF_SITUACAO_RFB = 'Inativo'
update DL_HistoricoInteracoes set PF_GENERO = 1 where PF_GENERO = 'Feminino'
update DL_HistoricoInteracoes set PF_GENERO = 0 where PF_GENERO = 'Masculino'
update DL_HistoricoInteracoes set PJ_SITUACAO = 1 where PJ_SITUACAO = 'Ativo'
update DL_HistoricoInteracoes set PJ_SITUACAO = 0 where PJ_SITUACAO = 'Inativo'
update DL_HistoricoInteracoes set PJ_SITUACAO_RFB = 1 where PJ_SITUACAO_RFB = 'Ativo'
update DL_HistoricoInteracoes set PJ_SITUACAO_RFB = 0 where PJ_SITUACAO_RFB = 'Inativo'
update DL_HistoricoInteracoes set PJ_PORTE = case PJ_PORTE when 'MEI' then 1 when 'ME' then 2 when 'EPP' then 3 end;
update DL_HistoricoInteracoes set PJ_SETOR = case PJ_SETOR when 'COMÉRCIO' then 1 when 'SERVIÇOS' then 2 when 'INDÚSTRIA' then 3 when 'AGRONEGOCIOS' then 4 end;
update DL_HistoricoInteracoes set ABORDAGEM_ATENDIMENTO = case ABORDAGEM_ATENDIMENTO when 'Individual' then 1 when 'Grupo' then 2 end;
update DL_HistoricoInteracoes set CANAL_ATENDIMENTO = case CANAL_ATENDIMENTO when 'Sistema CRM Nacional' then 1 when 'SisWebAtd' then 2 when 'EventManager' then 3 when 'TrackerAutomation' then 4 when 'SisEduc' then 5 when 'SisMobile/VOIP/Itinerante' then 6 end;
update DL_HistoricoInteracoes set INSTRUMENTO_ATENDIMENTO = case INSTRUMENTO_ATENDIMENTO when 'Orientações Técnicas' then 1 when 'Consultorias' then 2 when 'Informações Gerais' then 3 when 'Eventos' then 4 when 'Cursos' then 5 end;
ALTER TABLE DL_HistoricoInteracoes ALTER COLUMN PF_GENERO nvarchar(60) NULL
update DL_HistoricoInteracoes set PF_GENERO = NULL where PF_GENERO = 'Não se aplica/Não declarado'
update DL_HistoricoInteracoes set MEIO_ATENDIMENTO = case MEIO_ATENDIMENTO 
	when 'Pessoal' then 1 
	when 'Telefone' then 2 
	when 'Agência fixa' then 3 
	when 'E-mail' then 4 
	when 'Aplicativos' then 5 
	when 'Chat' then 6 
	when 'Parcerias com Governo' then 7 
	when 'Agência itinerante/temporária' then 8 
	when 'Inteligência Artificial' then 9 
	when 'Redes sociais' then 10 
	when 'Porta a porta' then 11 
	when 'Sala do Empreendedor' then 12 
	when 'Portal' then 13 
	when 'Auto-Atendimento Internet' then 14 
	when 'Carta' then 15 
	when 'Totens' then 16 
	when 'Auto-Atendimento Quiosque' then 17 
	when 'Fax' then 18 
end;
update DL_HistoricoInteracoes set PF_UF = case PF_UF 
	when 'MG' then 1 
	when 'RJ' then 2 
	when 'PA' then 3 
	when 'GO' then 4 
	when 'CE' then 5 
	when 'DF' then 6 
	when 'PE' then 7 
	when 'BA' then 8 
	when 'ES' then 9 
	when 'MA' then 10 
	when 'RN' then 11 
	when 'MT' then 12 
	when 'PB' then 13 
	when 'RO' then 14 
	when 'MS' then 15 
	when 'AL' then 16 
	when 'AM' then 17 
	when 'TO' then 18 
	when 'PI' then 19 
	when 'SC' then 20 
	when 'SE' then 21 
	when 'AC' then 22 
	when 'AP' then 23 
	when 'RR' then 24 
	when 'SP' then 25 
	when 'PR' then 26 
	when 'RS' then 27 
end;			
update DL_HistoricoInteracoes set PJ_UF = case PJ_UF 
	when 'MG' then 1 
	when 'RJ' then 2 
	when 'PA' then 3 
	when 'GO' then 4 
	when 'CE' then 5 
	when 'DF' then 6 
	when 'PE' then 7 
	when 'BA' then 8 
	when 'ES' then 9 
	when 'MA' then 10 
	when 'RN' then 11 
	when 'MT' then 12 
	when 'PB' then 13 
	when 'RO' then 14 
	when 'MS' then 15 
	when 'AL' then 16 
	when 'AM' then 17 
	when 'TO' then 18 
	when 'PI' then 19 
	when 'SC' then 20 
	when 'SE' then 21 
	when 'AC' then 22 
	when 'AP' then 23 
	when 'RR' then 24 
	when 'SP' then 25 
	when 'PR' then 26 
	when 'RS' then 27 
end;				
update DL_HistoricoInteracoes set TEMA_ATENDIMENTO = case TEMA_ATENDIMENTO 
	when 'Legislação e Fiscalização' then 1 
	when 'Impostos e Tributos' then 1 
	when 'Legislação' then 1 
	when 'Obrigação Previdenciária e Trabalhista' then 1 
	when 'Empreendedorismo' then 2 
	when 'Planejamento' then 3 
	when 'Plano de negócios' then 3 
	when 'Inovação' then 4 
	when 'Habitats de inovação' then 4 
	when 'Gestão' then 5 
	when 'Finanças' then 6 
	when 'Abertura de negócios' then 7 
	when 'Outros' then 8 
	when 'Crédito e Investimentos' then 9 
	when 'Mercado' then 10 
	when 'Tecnologia e Serviços Digitais' then 11 
	when 'Informatização de Empresas' then 11 
	when 'Extensão tecnológica' then 11 
	when 'Relacionamento e Gestão de Pessoas' then 12 
	when 'Produtividade' then 12 
	when 'Liderança' then 12 
	when 'Vendas' then 13 
	when 'Economia e Mercado' then 14
	when 'Políticas de Incentivo' then 14
	when 'Design' then 15 
	when 'Dívidas, Fechamento, Falência e Concordata' then 16 
	when 'Logística' then 17 
	when 'Mudanças' then 17 
	when 'Eventos' then 18 
	when 'Rede e Expansão' then 19 
	when 'Certificações e Registros' then 20 
	when 'Certificação' then 20 
	when 'Marketing' then 21 
	when 'Contabilidade' then 22 
	when 'Cooperação' then 23 
	when 'Sustentabilidade' then 24 
	when 'Seguros' then 25 
	when 'Exportação' then 26 
	when 'Agricultura' then 27 
	when 'Convênios' then 28 
	when 'Importação' then 29 
end;	
update DL_HistoricoInteracoes set TEMA_ATENDIMENTO = case TEMA_ATENDIMENTO 
	when 1  then 30
	when 20 then 30 
	when 6  then 31 
	when 9  then 31 
	when 16 then 31 
	when 22 then 31 
	when 25 then 31 
	when 11 then 32 
	when 2  then 33 
	when 7  then 33 
	when 3  then 34 
	when 5  then 34 
	when 10 then 34 
	when 12 then 34 
	when 19 then 34 
	when 28 then 34 
	when 14 then 35 
	when 17 then 35 
	when 23 then 35 
	when 26 then 35 
	when 29 then 35 
	when 4  then 36 
	when 18 then 36
	when 13 then 37
	when 15 then 37 
	when 21 then 37 
	when 8  then 38 
	when 24 then 38 
	when 27 then 38 
end;
/*
1: AMBIENTE NORMATIVO (30)
2: AMBIENTE FINANCEIRO (31)
3: AMBIENTE DE TECNOLOGIA (32)
4: AMBIENTE DE EMPREENDEDORISMO E NOVOS NEGÓCIOS (33)
5: AMBIENTE DE GESTÃO E MERCADOLÓGICO (34)
6: AMBIENTE ECONÔMICO E SOCIAL (35)
7: AMBIENTE DE INOVAÇÃO (36)
8: AMBIENTE DE MARKETING (37)
9: AMBIENTE DE CIÊNCIAS DA TERRA E SUSTENTABILIDADE (38)
*/

update DL_HistoricoInteracoes set TEMA_ATENDIMENTO = case TEMA_ATENDIMENTO 
	when 30  then 1
	when 31  then 2
	when 32  then 3
	when 33  then 4
	when 34  then 5
	when 35  then 6
	when 36  then 7
	when 37  then 8
	when 38  then 9
end;
update DL_HistoricoInteracoes set ABORDAGEM_ATENDIMENTO = 0 where ABORDAGEM_ATENDIMENTO = 1;
update DL_HistoricoInteracoes set ABORDAGEM_ATENDIMENTO = 1 where ABORDAGEM_ATENDIMENTO = 2;
update DL_HistoricoInteracoes set CATEGORIA_ATENDIMENTO = 0 where CATEGORIA_ATENDIMENTO = 1;
update DL_HistoricoInteracoes set CATEGORIA_ATENDIMENTO = 1 where CATEGORIA_ATENDIMENTO = 2;
/*
1: Analogógico (1,3,7,8,11,12,15) -- (Fixo, Presencial, In Loco, - Síncrono ou Assíncrono)
2: Remoto (2) -- (Duas partes existem em ambientes de atendimento distintos -  Síncrono)
3: Digital (4,6,10,13,18) -- (Informatizado, Totens, E-mail - Síncrono ou Assíncrono)
4: Virtual (5,9,14,17) -- (Ambiente e atendentes não existem na realidade - Síncrono)
*/
update DL_HistoricoInteracoes set MEIO_ATENDIMENTO = 0 where MEIO_ATENDIMENTO IN (1,2,3,4,7,8,11,12,15,18);
update DL_HistoricoInteracoes set MEIO_ATENDIMENTO = 1 where MEIO_ATENDIMENTO IN (5,6,9,10,13,14,16,17);

-- Análise após últimos tratamentos
SELECT 
	CONVERT(int,PF_GENERO) AS PF_GENERO,
	CONVERT(int,DATEDIFF(YY, PF_DT_NASCIMENTO, GETDATE())) AS PF_IDADE,
	CONVERT(int,PJ_PORTE) AS PJ_PORTE,
	CONVERT(int,PJ_SETOR) PJ_SETOR,
	CONVERT(int,DATEDIFF(YY, PJ_DT_ABERTURA, GETDATE())) AS PJ_IDADE,
	CONVERT(int,PJ_NUM_FUNCIONARIOS) AS PJ_NUM_FUNCIONARIOS,
	CONVERT(int,CANAL_ATENDIMENTO) AS CANAL_ATENDIMENTO,
	CONVERT(int,TEMA_ATENDIMENTO) AS TEMA_ATENDIMENTO,
	CONVERT(int,ABORDAGEM_ATENDIMENTO) AS ABORDAGEM_ATENDIMENTO,
	CONVERT(int,CATEGORIA_ATENDIMENTO) AS CATEGORIA_ATENDIMENTO,
	CONVERT(int,INSTRUMENTO_ATENDIMENTO) AS INSTRUMENTO_ATENDIMENTO,
	CONVERT(int,MEIO_ATENDIMENTO) AS MEIO_ATENDIMENTO
FROM
	DL_HistoricoInteracoes 
WHERE PF_SITUACAO_RFB = 1 AND PJ_SITUACAO_RFB = 1 
	  AND PF_GENERO IS NOT NULL AND CONVERT(int,DATEDIFF(YY, PF_DT_NASCIMENTO, GETDATE())) BETWEEN 18 AND 89;
-- Mais análises após últimos tratamentos	  
SELECT
	PF_GENERO AS PF_GENERO,
	DATEDIFF(YY, PF_DT_NASCIMENTO, GETDATE()) AS PF_IDADE,
	PJ_PORTE AS PJ_PORTE,
	PJ_SETOR PJ_SETOR,
	DATEDIFF(YY, PJ_DT_ABERTURA, GETDATE()) AS PJ_IDADE,
	PJ_NUM_FUNCIONARIOS AS PJ_NUM_FUNCIONARIOS,
	CANAL_ATENDIMENTO AS CANAL_ATENDIMENTO,
	TEMA_ATENDIMENTO AS TEMA_ATENDIMENTO,
	ABORDAGEM_ATENDIMENTO AS ABORDAGEM_ATENDIMENTO,
	CATEGORIA_ATENDIMENTO AS CATEGORIA_ATENDIMENTO,
	INSTRUMENTO_ATENDIMENTO AS INSTRUMENTO_ATENDIMENTO,
	MEIO_ATENDIMENTO AS MEIO_ATENDIMENTO
FROM
	DL_HistoricoInteracoes 
WHERE PF_SITUACAO_RFB = 1 AND PJ_SITUACAO_RFB = 1 
-- Verificação de duplicidades após últimas intervenções e transformações
WITH X AS   (SELECT 
				   CPF,
				   CNPJ,
				   PF_GENERO,
				   PF_DT_NASCIMENTO,
				   PJ_PORTE,
				   PJ_SETOR,
				   PJ_DT_ABERTURA,
				   PJ_NUM_FUNCIONARIOS,
				   CANAL_ATENDIMENTO,
				   TEMA_ATENDIMENTO,
				   ABORDAGEM_ATENDIMENTO,
				   CATEGORIA_ATENDIMENTO,
				   INSTRUMENTO_ATENDIMENTO,
				   MEIO_ATENDIMENTO
			,RN = ROW_NUMBER()
            OVER(PARTITION BY 
				   CPF,
				   CNPJ,
				   PF_GENERO,
				   PF_DT_NASCIMENTO,
				   PJ_PORTE,
				   PJ_SETOR,
				   PJ_DT_ABERTURA,
				   PJ_NUM_FUNCIONARIOS,
				   CANAL_ATENDIMENTO,
				   TEMA_ATENDIMENTO,
				   ABORDAGEM_ATENDIMENTO,
				   CATEGORIA_ATENDIMENTO,
				   INSTRUMENTO_ATENDIMENTO,
				   MEIO_ATENDIMENTO
				 ORDER BY CPF)
            FROM DL_HistoricoInteracoes)
SELECT * FROM X
WHERE RN > 1
-- Verificação de duplicidades após últimas intervenções e transformações (isoladas somente com variáveis que compõem dataset)
WITH X AS   (SELECT 
				   --CPF,
				   --CNPJ,
				   PF_GENERO,
				   PF_DT_NASCIMENTO,
				   PJ_PORTE,
				   PJ_SETOR,
				   PJ_DT_ABERTURA,
				   PJ_NUM_FUNCIONARIOS,
				   CANAL_ATENDIMENTO,
				   TEMA_ATENDIMENTO,
				   ABORDAGEM_ATENDIMENTO,
				   CATEGORIA_ATENDIMENTO,
				   INSTRUMENTO_ATENDIMENTO,
				   MEIO_ATENDIMENTO
			,RN = ROW_NUMBER()
            OVER(PARTITION BY 
				   --CPF,
				   --CNPJ,
				   PF_GENERO,
				   PF_DT_NASCIMENTO,
				   PJ_PORTE,
				   PJ_SETOR,
				   PJ_DT_ABERTURA,
				   PJ_NUM_FUNCIONARIOS,
				   CANAL_ATENDIMENTO,
				   TEMA_ATENDIMENTO,
				   ABORDAGEM_ATENDIMENTO,
				   CATEGORIA_ATENDIMENTO,
				   INSTRUMENTO_ATENDIMENTO,
				   MEIO_ATENDIMENTO
				 ORDER BY PF_DT_NASCIMENTO)
            FROM DL_HistoricoInteracoes)
-- SELECT * FROM X WHERE RN > 1
DELETE FROM X WHERE RN > 1
/* #######################################################################
>>>>>>>>>>> SCRIPT FINAL PARA CRIAÇÃO DO DATASET PARA K MEANS <<<<<<<<<<<<
####################################################################### */
 SELECT
     CONVERT(int,PF_GENERO) AS PF_GENERO,
     CONVERT(int,DATEDIFF(YY, PF_DT_NASCIMENTO, GETDATE())) AS PF_IDADE,
     CONVERT(int,PJ_PORTE) AS PJ_PORTE,
     CONVERT(int,PJ_SETOR) PJ_SETOR,
     CONVERT(int,DATEDIFF(YY, PJ_DT_ABERTURA, GETDATE())) AS PJ_IDADE,
     CONVERT(int,PJ_NUM_FUNCIONARIOS) AS PJ_NUM_FUNCIONARIOS,
     CONVERT(int,CANAL_ATENDIMENTO) AS CANAL_ATENDIMENTO,
     CONVERT(int,TEMA_ATENDIMENTO) AS TEMA_ATENDIMENTO,
     CONVERT(int,ABORDAGEM_ATENDIMENTO) AS ABORDAGEM_ATENDIMENTO,
     CONVERT(int,CATEGORIA_ATENDIMENTO) AS CATEGORIA_ATENDIMENTO,
     CONVERT(int,INSTRUMENTO_ATENDIMENTO) AS INSTRUMENTO_ATENDIMENTO,
     CONVERT(int,MEIO_ATENDIMENTO) AS MEIO_ATENDIMENTO
 FROM
     DL_HistoricoInteracoes 
 WHERE PF_SITUACAO_RFB = 1 AND PJ_SITUACAO_RFB = 1 
       AND PF_GENERO IS NOT NULL AND CONVERT(int,DATEDIFF(YY, PF_DT_NASCIMENTO, GETDATE())) BETWEEN 18 AND 88;
