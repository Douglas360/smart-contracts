// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importação dos contratos ERC721 e Ownable do OpenZeppelin para funcionalidades de tokens não fungíveis (NFT) e controle de propriedade
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Contrato para criação e gerenciamento de NFTs (Non-Fungible Tokens)
contract MyNFT is ERC721, Ownable {
    // Variável para rastrear o próximo ID disponível para um novo NFT
    uint256 public nextTokenId;
    // Mapeamentos para armazenar metadados adicionais dos NFTs
    mapping(uint256 => string) private _tokenMetadata; // URI dos tokens
    mapping(uint256 => address) private _tokenCreators; // Criador dos tokens
    mapping(uint256 => uint256) private _tokenRoyalties; // Taxa de royalties dos tokens

    // Evento emitido quando um novo NFT é mintado
    event NFTMinted(uint256 indexed tokenId, address indexed creator, uint256 royalty);
    // Evento emitido quando um NFT é transferido
    event NFTTransferred(uint256 indexed tokenId, address indexed from, address indexed to);
    // Evento emitido quando a taxa de royalties de um NFT é atualizada
    event RoyaltiesUpdated(uint256 indexed tokenId, uint256 newRoyalty);

    // Construtor do contrato para definir o nome e o símbolo do NFT
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        nextTokenId = 1;
    }

    // Função para criar um novo NFT
    function createNFT(address _to, string memory _tokenURI, uint256 _royalty) external onlyOwner returns (uint256) {
        // Obter o próximo ID disponível para o novo NFT
        uint256 tokenId = nextTokenId;
        // Mintar o novo NFT para o endereço especificado
        _safeMint(_to, tokenId);
        // Definir o URI do token
        _setTokenURI(tokenId, _tokenURI);
        // Registrar o criador e a taxa de royalties do token
        _tokenCreators[tokenId] = _to;
        _tokenRoyalties[tokenId] = _royalty;
        // Incrementar o próximo ID disponível
        nextTokenId++;
        // Emitir evento de mintagem do NFT
        emit NFTMinted(tokenId, _to, _royalty);
        return tokenId;
    }

    // Função para atualizar a taxa de royalties de um NFT
    function updateRoyalty(uint256 _tokenId, uint256 _newRoyalty) external {
        require(_exists(_tokenId), "Token does not exist");
        // Verificar se o chamador é o proprietário do contrato ou o criador do token
        require(_msgSender() == owner() || _msgSender() == _tokenCreators[_tokenId], "Not authorized");
        // Atualizar a taxa de royalties do token
        _tokenRoyalties[_tokenId] = _newRoyalty;
        // Emitir evento de atualização de royalties
        emit RoyaltiesUpdated(_tokenId, _newRoyalty);
    }

    // Função de transferência de tokens com sobreposição para emitir evento
    function transferFrom(address from, address to, uint256 tokenId) public override {
        super.transferFrom(from, to, tokenId);
        // Emitir evento de transferência de token
        emit NFTTransferred(tokenId, from, to);
    }

    // Função para definir o URI do token
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _setTokenURI(tokenId, _tokenURI);
    }

    // Função para obter o URI do token
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenMetadata[tokenId];
    }

    // Função para obter o criador de um token
    function getCreator(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenCreators[tokenId];
    }

    // Função para obter a taxa de royalties de um token
    function getRoyalty(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenRoyalties[tokenId];
    }
}
