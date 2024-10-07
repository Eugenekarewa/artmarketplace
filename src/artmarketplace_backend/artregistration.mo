import { Nat, Principal, Vec, Option, Result } from "mo:base/Prelude";

// Define data structures
type ArtPieceId = Nat;
type Price = Nat;

type ArtPiece = {
    id: ArtPieceId;
    title: Text;
    description: Text;
    artist: Principal;
    price: Price;
    medium: Text;
    dimensions: Text;
    image_url: Option<Text>; // Optional: Store image URLs or references
};

type CreateArtRequest = {
    title: Text;
    description: Text;
    artist: Principal;
    price: Price;
    medium: Text;
    dimensions: Text;
    image_url: Option<Text>; // Optional: Allow image URLs to be optional
};

type UpdateArtRequest = {
    id: ArtPieceId;
    title: Option<Text>;
    description: Option<Text>;
    price: Option<Price>;
    medium: Option<Text>;
    dimensions: Option<Text>;
    image_url: Option<Text>;
};

type SearchArtRequest = {
    artist: Option<Principal>;
    title: Option<Text>;
    price_min: Option<Price>;
    price_max: Option<Price>;
    medium: Option<Text>;
    dimensions: Option<Text>;
};

type SearchArtResponse = {
    results: Vec<ArtPiece>;
};

// Define canister state
actor ArtRegistry {
    stable var art_pieces: Vec<ArtPiece> = [];

    public query func search_art(request: SearchArtRequest) : async SearchArtResponse {
        let mut results: Vec<ArtPiece> = [];
        for (art_piece in art_pieces.vals()) {
            if ( (request.artist.is_none() || art_piece.artist == request.artist.unwrap()) &&
                 (request.title.is_none() || art_piece.title == request.title.unwrap()) &&
                 (request.price_min.is_none() || art_piece.price >= request.price_min.unwrap()) &&
                 (request.price_max.is_none() || art_piece.price <= request.price_max.unwrap()) &&
                 (request.medium.is_none() || art_piece.medium == request.medium.unwrap()) &&
                 (request.dimensions.is_none() || art_piece.dimensions == request.dimensions.unwrap()) 
            ) {
                results.push(art_piece);
            }
        }
        return { results };
    }

    public query func get_art(id: ArtPieceId) : async Option<ArtPiece> {
        return art_pieces.find(func(art) { art.id == id });
    }

    public update func create_art(request: CreateArtRequest) : async ArtPieceId {
        let id = art_pieces.size() + 1;
        let art_piece = ArtPiece {
            id,
            title: request.title,
            description: request.description,
            artist: request.artist,
            price: request.price,
            medium: request.medium,
            dimensions: request.dimensions,
            image_url: request.image_url,
        };
        art_pieces.append(art_piece);
        return id;
    }

    public update func update_art(request: UpdateArtRequest) : async Result<(), Text> {
        let index = art_pieces.find_index(func(art) { art.id == request.id });
        switch (index) {
            case (?i) {
                let art_piece = &mut art_pieces[i];
                if (request.title != null) { art_piece.title := request.title.unwrap(); }
                if (request.description != null) { art_piece.description := request.description.unwrap(); }
                if (request.price != null) { art_piece.price := request.price.unwrap(); }
                if (request.medium != null) { art_piece.medium := request.medium.unwrap(); }
                if (request.dimensions != null) { art_piece.dimensions := request.dimensions.unwrap(); }
                if (request.image_url != null) { art_piece.image_url := request.image_url.unwrap(); }
                return #ok(());
            };
            case null { return #err("Art piece not found"); }
        }
    }

    public update func delete_art(id: ArtPieceId) : async Result<(), Text> {
        let index = art_pieces.find_index(func(art) { art.id == id });
        switch (index) {
            case (?i) {
                art_pieces.swap_remove(i);
                return #ok(());
            };
            case null { return #err("Art piece not found"); }
        }
    }
};
