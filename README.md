  TESTE TÉCNICO - SISTEMA DE PEDIDOS DE VENDA
  Desenvolvido em Delphi 10.2 Tokyo + MySQL 5.7

--------------------------------------------------------------------------------
  REQUISITOS DE AMBIENTE
--------------------------------------------------------------------------------

  - Delphi 10.2 Tokyo (32 bits)
  - MySQL 5.7 (32 bits)
  - Biblioteca libmysql.dll localizada em: C:\teste\
  - Aplicação deve estar na raiz do disco C: (C:\teste\)
  - No meu computador tive que colocar o caminho da lib nas variáveis de ambiente

--------------------------------------------------------------------------------
  CONFIGURAÇÃO ANTES DE EXECUTAR
--------------------------------------------------------------------------------

  Antes de executar o sistema, crie o arquivo config.ini localizado em:

    C:\teste\Source\config.ini

  Configure os parâmetros de conexão conforme seu ambiente:

    [Database]
    Server=localhost
    Port=3306
    Database=db_pedidos
    User=root
    Password=suasenha

  Salve o arquivo e execute o sistema normalmente.

--------------------------------------------------------------------------------
  CONFIGURAÇÃO DO BANCO DE DADOS
--------------------------------------------------------------------------------

  O sistema possui uma tela de administração (Funções Database) com dois botões:

  1. CRIAR BANCO DE DADOS
     Dropa o banco db_pedidos caso já exista e o recria do zero,
     Zera todas as tabelas via TRUNCATE e recarrega os dados padrão:
     - 20 clientes de diferentes estados
     - 20 produtos com preços variados
     - 10 pedidos com múltiplos itens cada

  Também é possível executar o script banco_pedidos.sql diretamente
  no MySQL Workbench ou via linha de comando.

--------------------------------------------------------------------------------
  ARQUITETURA E CONCEITOS UTILIZADOS
--------------------------------------------------------------------------------

  POO - PROGRAMAÇÃO ORIENTADA A OBJETOS
  --------------------------------------
  O projeto foi desenvolvido aplicando conceitos de POO, incluindo:

  - Herança de formulários: todos os formulários de cadastro herdam de
    TFrmCad (formulário base), que possui os botões padrão (Novo, Editar,
    Salvar, Excluir, Cancelar) e o grid de consulta (CardBrowse).
    Os formulários filhos herdam essa estrutura e adicionam seus
    campos específicos no CardCreate.

  - Encapsulamento: dados e comportamentos agrupados em classes
    com visibilidade correta (private, protected, public).

  INTERFACES E CLASSES - ICrud
  -----------------------------
  Foi criada uma interface ICrud que define o contrato de operações
  de banco de dados:

    ICrud = interface
      function UpdateOrInsert(Data: TFDMemTable; ATransaction: TFDTransaction; ACodeOrder: Integer): Boolean;
      function Delete(Data: TFDMemTable; ATransaction: TFDTransaction; ACodeOrder: Integer): Boolean;
      function DeleteItemById(AItems: TList<TOrderItemDeleted>; ATransaction: TFDTransaction): Boolean;
    end;

  A classe base TCrud implementa ICrud e é responsável por:
  - Guardar a conexão com o banco (FConnection)
  - Criar e destruir o TFDQuery (FSqlSave) utilizado nas operações
  - Definir os métodos como virtual abstract, forçando as classes
    filhas a implementarem o SQL específico de cada tabela

  As classes filhas (ex: TCrudSalesOrderProduct) herdam de TCrud
  e implementam o SQL explícito de cada operação, respeitando
  o contrato definido pela interface.

  USO DE SQL EXPLÍCITO
  ---------------------
  Conforme solicitado no teste, priorizei o uso de SQL explícito
  em todas as operações de escrita (INSERT, UPDATE, DELETE).
  O TFDQuery é utilizado apenas para leitura (SELECT) nos grids
  e consultas de apoio.

  Para os itens do pedido em edição, utilizei TFDMemTable, uma
  tabela em memória que permite usar Append/Post sem tocar no banco.
  Isso possiblilita montar os itens do pedido em memória e só
  executar o SQL quando o operador confirmar a gravação, mantendo
  o controle total sobre as instruções SQL executadas.

  TRANSAÇÕES
  -----------
  A gravação do pedido utiliza TFDTransaction instanciado via código,
  garantindo que o cabeçalho (pedidos_geral) e os itens
  (pedidos_produtos) sejam gravados juntos ou não sejam gravados
  nenhum — com Rollback automático em caso de erro.

  TRATAMENTO DE EXCEÇÕES
  -----------------------
  Todas as operações críticas possuem tratamento de exceção com
  try/except/finally, garantindo:
  - Rollback da transação em caso de erro
  - Liberação correta de memória (Free) via finally
  - Mensagem de erro clara para o operador

  FINALIZAÇÃO CORRETA DAS CLASSES
  ---------------------------------
  Todas as classes instanciadas via código são corretamente
  finalizadas no bloco finally, evitando vazamento de memória.
  As classes que implementam TInterfacedObject têm seu ciclo
  de vida gerenciado automaticamente pelo Delphi via contagem
  de referência da interface.

  FRMLOOKUP
  ----------
  Foi criado um formulário FrmLookup de uso genérico para pesquisa
  de registros. Ele recebe a tabela, os campos e o filtro via
  parâmetro, exibe os resultados em um grid e retorna o registro
  selecionado para o formulário que o chamou. Evita duplicação
  de código de pesquisa em diferentes telas.

  UTILITÁRIO TSQLUTILS
  ---------------------
  Foi criada a classe TSqlUtils com o método estático Locate,
  que realiza buscas em qualquer tabela recebendo como parâmetro:
  - Nome da tabela
  - TFDQuery a ser preenchido
  - Valor a buscar
  - Campo de busca
  - Array de campos a retornar

  Isso elimina código repetitivo de busca em diferentes telas.

--------------------------------------------------------------------------------
  TELA DE PEDIDO DE VENDA
--------------------------------------------------------------------------------

  A tela de pedido de venda utiliza TCardPanel com dois cards:

  CARDBROWSE (Consulta)
  - Exibe todos os pedidos em um DBGrid
  - Botão F7 - A partir de: carrega um pedido existente pelo número
    informado pelo operador, preenchendo cliente e produtos
  - Botão Excluir: solicita o número do pedido e apaga o cabeçalho
    e os itens (via ON DELETE CASCADE no banco)
  - Navegação completa pelos pedidos gravados

  CARDCREATE (Cadastro)
  - Campos de cabeçalho: código e nome do cliente (nome preenchido
    automaticamente ao digitar o código)
  - Grid de itens usando TFDMemTable + TDBGrid
  - Campos de produto com busca automática ao digitar o código
  - Botões de produto com atalhos de teclado:
      F3 - Cadastrar novo item
      F4 - Editar item selecionado
      F5 - Gravar item
      F6 - Deletar item (com confirmação)
      Esc - Cancelar edição do item
  - Rodapé com total de quantidade e valor total calculados
    automaticamente via aggregate no TFDMemTable
  - Botão Gravar Pedido: salva cabeçalho e itens em transação


--------------------------------------------------------------------------------
  OBSERVAÇÕES FINAIS
--------------------------------------------------------------------------------

  - Ambos Delphi 10.2 e MySQL 5.7 utilizados na versão 32 bits,
    garantindo compatibilidade total entre executável e biblioteca
    do cliente MySQL.

  - O arquivo config.ini é criado automaticamente na primeira
    execução caso não exista, com valores padrão de conexão.

  - Em caso de dúvidas sobre configuração, entrar em contato.
  
 

--------------------------------------------------------------------------------

	Desenvolvido por Paulo Henrique Figueiredo Marques
