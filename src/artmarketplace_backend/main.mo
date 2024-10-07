import artregistration "artregistration";
import marketplace "marketplace";
import nft "nft";
import payment "payment";
actor {
  stable var artworks = artregistration.init();
  stable var users = marketplace.init();
  stable var nft=nft.init();
  stable var payment=payment.init();

  public query func listArtworks() : async [Artwork.ArtworkDetails] {
    return artworks.list();
  };

  public func createArtwork(title: Text, creator: Text, price: Nat) {
    artworks.add(title, creator, price);
  };

  public func buyArtwork(artworkId: Nat, buyer: Text) {
    let user = User.getUser(buyer);
    Transaction.buy(artworkId, user, artworks);
  }
}
