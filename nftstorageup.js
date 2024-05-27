const { NFTStorage, File } = require('nft.storage');

const uploadToNFTStorage = async (metadata) => {
  const apiKey = localStorage.getItem('nft_STORAGE_API_KEY');
  const client = new NFTStorage({ token: apiKey });

  const metadataFile = new File([JSON.stringify(metadata)], 'metadata.json', { type: 'application/json' });
  const cid = await client.storeBlob(metadataFile);

  return `ipfs://${cid}`;
};

