// Example function to create and upload metadata, then mint an NFT
const createAndMintNFT = async (name, description, image, apiName) => {
  const metadata = createMetadata(name, description, image);
  let tokenUri;

  switch (apiName.toLowerCase()) {
    case 'web3.storage':
      tokenUri = await uploadToWeb3Storage(metadata);
      break;
    case 'nft.storage':
      tokenUri = await uploadToNFTStorage(metadata);
      break;
    case 'ipfs':
      tokenUri = await uploadToIPFS(metadata);
      break;
    default:
      throw new Error('Unsupported API');
  }

  return await mintNFT(tokenUri);
};

// Example usage
document.getElementById('api-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  const apiName = document.getElementById('api-name').value;
  const apiKey = document.getElementById('api-key').value;
  localStorage.setItem(`${apiName}_API_KEY`, apiKey);

  const name = 'Test NFT';
  const description = 'This is a test NFT';
  const image = 'ipfs://your-image-cid'; // Replace with actual image CID
  const tokenUri = await createAndMintNFT(name, description, image, apiName);

  displayTokenUri(tokenUri);
});

