module {
    public type TokenId = Nat;
    public type Category = {
        #art;
        #music;
        #trading card;
        #collectibles;
        #sports;
        #utility;
    };

    public type ItemDetails = {
        canisterId : Text;
        tokenId : TokenId;
        
    }
}