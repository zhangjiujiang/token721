import Utils "utils";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Option "mo:base/Option";
import Hash "mo:base/Hash";
import Array "mo:base/Array";

actor class Token(){

    type TokenMeta = {
        

    };

    type TokenId = Nat;
    func token_hash(tokenId : TokenId) : Hash.Hash{
        Hash.hash(tokenId);
    };
    ///mapping from nft to owner 
    private var nftToOwner = HashMap.HashMap<TokenId,Principal>(1,Nat.equal,token_hash);
    ///mapping from nft to approced principal
    private var nftToApproval = HashMap.HashMap<TokenId,Principal>(1,Nat.equal,token_hash);
    private var ownerToOperators = HashMap.HashMap<Principal,HashMap.HashMap<Principal,Bool>>(1,Principal.equal,Principal.hash);
    ///mapping from owner to their token count
    private var ownerToNftCount = HashMap.HashMap<Principal,Nat>(1,Principal.equal,Principal.hash);
    ///mapping from owner to their nft tokenId
    private var tokens = HashMap.HashMap<Principal,[var TokenId]>(1,Principal.equal,Principal.hash);

    public shared(msg) func balanceOf(owner : Principal) : async Nat {
        switch(ownerToNftCount.get(msg.caller)){
            case (?balance){
                balance;
            };
            case _ {
                0;
            };
        }
    };

    public shared(msg) func ownerOf(tokenId : TokenId) : async Principal {
        Option.unwrap(nftToOwner.get(tokenId));
    };

    public shared(msg) func safeTransferFrom(from : Principal , to : Principal , tokenId : TokenId) : async Bool{
        _canTransfer(msg.caller,from,to,tokenId);
        _transfer(from,to,tokenId);
        true;
    };

    public shared(msg) func transferFrom(from : Principal , to : Principal , tokenId : TokenId) : async Bool{
        _canTransfer(msg.caller,from,to,tokenId);
        _transfer(from,to,tokenId);
        true;
    };
    
    public shared(msg) func approve(approved : Principal , tokenId : TokenId) : async Bool{
        _canOperate(msg.caller,tokenId);
        nftToApproval.put(tokenId,approved);
        true;
    };

    public shared(msg) func setApprovalForAll(_operator : Principal , approve : Bool) : async Bool{
       switch(ownerToOperators.get(msg.caller)){
           case (?approvedOperator){
                approvedOperator.put(_operator,approve);
                ownerToOperators.put(msg.caller,approvedOperator);
                return true;
           };
           case _ {
               let approvedOperator = HashMap.HashMap<Principal,Bool>(1,Principal.equal,Principal.hash);
               approvedOperator.put(_operator,approve);
               ownerToOperators.put(msg.caller,approvedOperator);
               return true;
           };
           
       }
    };

    public shared(msg) func getApproved(tokenId : TokenId) : async Principal {
        assert(msg.caller == Option.unwrap(nftToOwner.get(tokenId)));
        return Option.unwrap(nftToApproval.get(tokenId));
    };

    public shared(msg) func isApprovedForAll(owner : Principal, _operator : Principal) : async Bool {
        let approvedOperators = Option.unwrap(ownerToOperators.get(owner));
        switch (approvedOperators.get(_operator)){
            case (?approced){
                approced
            };
            case _ {return false};
        }
    };
    
    //swap 功能
    public shared(msg) func mint(to: Principal, tokenId : TokenId): async Bool {
        let tokenOwner = Option.unwrap(nftToOwner.get(tokenId));
        assert(msg.caller == tokenOwner);
        assert( to != msg.caller);
        _addNftToken(to,tokenId);
        true;
    };

    public shared(msg) func burn(from: Principal, tokenId : TokenId) : async Bool {
        let tokenOwner = Option.unwrap(nftToOwner.get(tokenId));
        _clearApproval(tokenId);
        _removeNftToken(tokenOwner,tokenId);
        true;
    };

    //TODO 如何铸币 ????????????????

    
    private func _canTransfer(caller : Principal,from : Principal, to : Principal,tokenId : TokenId){
        let tokenOwner = Option.unwrap(nftToOwner.get(tokenId));
        let approver = Option.unwrap(nftToApproval.get(tokenId));
        let approvedOperators = Option.unwrap(ownerToOperators.get(tokenOwner));
        let approved : Bool = Option.unwrap(approvedOperators.get(caller));
        ///必须是转向其他人
        assert (from == tokenOwner and from != to);
        ///token所有者/被授权者/被授权的机构  "NOT_OWNER_APPROVED_OR_OPERATOR"
        assert (caller == tokenOwner or caller == approver or true == approved);
    };

    ///token所有者或者被授权者可以操作
    private func _canOperate(caller : Principal , tokenId : TokenId) {
        let tokenOwner = Option.unwrap(nftToOwner.get(tokenId));
        let approvedOperators = Option.unwrap(ownerToOperators.get(tokenOwner));
        let approved : Bool = Option.unwrap(approvedOperators.get(caller));
        assert (tokenOwner == caller or true == approved);
    };

    private func _transfer(from : Principal , to : Principal , tokenId : TokenId){
        let tokenOwner = Option.unwrap(nftToOwner.get(tokenId));
        assert(from == tokenOwner);
        _clearApproval(tokenId);
        _removeNftToken(from,tokenId);
        _addNftToken(to,tokenId);
    };

    private func _clearApproval(tokenId : TokenId){
        switch(nftToApproval.get(tokenId)){
            case (?approver){
                nftToApproval.delete(tokenId);
            };
            case _ {};
        }
    };

    private func _removeNftToken(owner : Principal , tokenId : TokenId){
        switch (ownerToNftCount.get(owner),nftToOwner.get(tokenId),tokens.get(owner)){
            case (?count,?owner,?tokenIds){
                ownerToNftCount.put(owner,count -1);
                nftToOwner.delete(tokenId);
                tokens.put(owner,Utils.filter(tokenIds,tokenId,Nat.equal));
            };
            case _ {};
        };
    };

    private func _addNftToken(to : Principal , tokenId : TokenId){
        switch(ownerToNftCount.get(to)){
            case (?count){
                ownerToNftCount.put(to,count + 1);
            };
            case _ {
                ownerToNftCount.put(to,1);
            };
        };
        nftToOwner.put(tokenId,to);
        switch(tokens.get(to)){
            case (?tokenIds){
                tokens.put(to,Array.thaw(Array.append(Array.freeze(tokenIds),Array.make(tokenId))));
            };
            case _ {
                let tokenIdss = Array.thaw<TokenId>(Array.make<TokenId>(tokenId));
                tokens.put(to,tokenIdss);
            };
        }
    };
};
