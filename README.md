# bloBox

Blob-API starts the server that proccesses incoming requests from Blob-Client and games (Blob-Pong, Blob-Werewolf), handles authentication, updates the database, etc.

## Main Features Overview
Blob-API provides bloBox with NFT creation capability, BLOB token withdrawal, and handling of the deposit.

Three contracts are created for those purposes:
* Blob - an ERC20 token of bloBox

* BlobManager - contains and manages most of the BLOB supply

* BlobNFT - NFT-skins

all of which are deployed on the C-Chain (for now on Fuji).

#
In Blob-Client inside the Wallet section users can set their wallet address and withdraw a specific amount of BLOBs that they have in their withdrawable balance (withdrawable meaning that only BLOBs awarded by playing games can be withdrawn).

After doing so, Blob-Client calls the endpoint

<code>
POST /api/transactions/withdraw
</code>  

which will call the

<code>
function requestWithdrawal(address userAddress, uint256 totalAmount) external onlyOwner
</code>

of the BlobManager, thereby transfering BLOBs to the user's wallet. Blob-API updates the balance if that operation succeeds.

Withdrawal was tested by performing 20+ withdrawals to different accounts at the same time, all of which succeeded. If an error were to occur, the error handling will retry the operations thanks to the correct nonce and gas management.

#
In the Draw Yourself section of the client users can create their own NFT-skin by owning a specific key. Those keys will be rewared to users on different occasions like "First Werewolf Win", "50 Wins", etc. To create a skin, users have to provide name and description, choose a 3D model from the list of available models associated with the key, and choose the texture which will be applied on the model.

After submission, client makes request 

<code>
POST /api/user/nft
</code>

which will create an NFT by providing the necessarry information in the metadata.json

<code>

    "name": "God",
    "description": "Breathtaking",
    "image": "ipffs://some-cid-of-texture-image",
    "attributes":
    [
        {
            "trait_type": "Game",
            "value": "Werewolf"
        },
        {
            "trait_type": "Model",
            "value": "Apollo"
        }
    ]
</code>

and storing it in Pinata after minting the NFT.

Afterwards the list of available NFT-skins is fetched by calling

<code>
GET /api/user/nft
</code>

which searches for BlobNFTs in user's wallet by utilising Glacier API - making the following request

<code>
GET
https://glacier-api.avax.network/v1/chains/{chainId}/addresses/{walletAddress}/balances:listErc721?contractAddress={contractAddress}
</code>


The client will apply the texture on the specific model (this information is stored in the metadata: texture in image, and 3D model info in attributes) and show it.
#
Users can also set the default skin by calling

<code>
POST /api/nft/user/default
</code>

and get it by

<code>
GET /api/nft/user/default
</code>

which makes request to Glacier API, and before returning the NFT checks if it still belongs to the user.

#

Depositing works thanks to the webhook created in AvaCloud. Whenever a user transfers BLOBs from their wallet (either from Core, Metamask, etc.), this webhook makes request to Blob-API

<code>
POST /api/blockchain/webhooks/transfer
</code>


If user made deposit to the BlobManager, their balance will be updated.