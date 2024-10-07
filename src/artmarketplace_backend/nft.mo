import { canister_ts, Nat, Principal, Vec } from "motoko/stdlib";

// Define data structures
type NFTId = Nat;

type NFT = {
    id: NFTId;
    owner: Principal;
    art_piece_id: ArtPieceId;
    metadata: Text; // Store metadata about the art piece
};

// Define canister state
actor NFTCanister {
    var nfts: Vec<NFT>;

    public query get_nft(id: NFTId) -> Option<NFT> {
        nfts.find(nft => nft.id == id)
    }

    public update mint_nft(owner: Principal, art_piece_id: ArtPieceId, metadata: Text) -> NFTId {
        let id = nfts.len() as NFTId + 1;
        let nft = NFT {
            id,
            owner,
            art_piece_id,
            metadata,
        };
        nfts.push(nft);
        id
    }

    public update transfer_nft(id: NFTId, new_owner: Principal) -> Result<(), Text> {
        let index = nfts.find_index(nft => nft.id == id);
        if let Some(index) = index {
            let nft = &mut nfts[index];
            if nft.owner == Principal.self {
                nft.owner = new_owner;
                Ok(())
            } else {
                Err("You are not the owner of this NFT")
            }
        } else {
            Err("NFT not found")
        }
    }

    public query verify_nft_ownership(id: NFTId, owner: Principal) -> bool {
        let nft = nfts.find(nft => nft.id == id);
        if let Some(nft) = nft {
            nft.owner == owner
        } else {
            false
        }
    }
};