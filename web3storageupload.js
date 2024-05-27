const { Web3Storage, File } = require('web3.storage');

const uploadToWeb3Storage = async (metadata) => {
  const apiKey = localStorage.getItem('web3_STORAGE_API_KEY');
  const client = new Web3Storage({ token: apiKey });

  const metadataFile = new File([JSON.stringify(metadata)], 'metadata.json', { type: 'application/json' });
  const cid = await client.put([metadataFile]);

  return `ipfs://${cid}/metadata.json`;
};

