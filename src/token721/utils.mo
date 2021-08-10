import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Order "mo:base/Order";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
module {
    public func filter<T>(xs:[var T] , t : T,f:(T,T)->Bool) : [var T]{
        let ys : Buffer.Buffer<T> = Buffer.Buffer(xs.size());
        label l for (x in xs.vals()) {
            if(f(x,t)){
                continue l;
            };
            ys.add(x);
        };
        return ys.toVarArray();
    };

    type Order = Order.Order;

    // Sort the elements of an array using the given comparison function.
    public func sortBy<X>(xs : [var X], f : (X, X) -> Order) : [var X] {
        let n = xs.size();
        if (n < 2) {
            return xs;
        } else {
        sortByHelper<X>(xs, 0, n - 1, f);
            return xs;
        };
    };

    private func sortByHelper<X>(
        xs : [var X],
        l : Int,
        r : Int,
        f : (X, X) -> Order,
    ) {
        if (l < r) {
        var i = l;
        var j = r;
        var swap  = xs[0];
        let pivot = xs[Int.abs(l + r) / 2];
        while (i <= j) {
            while (Order.isLess(f(xs[Int.abs(i)], pivot))) {
            i += 1;
            };
            while (Order.isGreater(f(xs[Int.abs(j)], pivot))) {
            j -= 1;
            };
            if (i <= j) {
            swap := xs[Int.abs(i)];
            xs[Int.abs(i)] := xs[Int.abs(j)];
            xs[Int.abs(j)] := swap;
            i += 1;
            j -= 1;
            };
        };
        if (l < j) {
            sortByHelper<X>(xs, l, j, f);
        };
        if (i < r) {
            sortByHelper<X>(xs, i, r, f);
        };
        };
    };


    ///map转数组
    public func mapToArray<K,V>(map : HashMap.HashMap<K,V>) : [(K,V)] {
        return Iter.toArray(map.entries());

    };

    ///数组转map
    public func arrayToMap<K,V> (array : [(K,V)] , keyEq : (K,K) -> Bool, keyHash : K -> Hash.Hash) : HashMap.HashMap<K,V>{
        return HashMap.fromIter<K,V>(array.vals(), 1, keyEq, keyHash);
    };

}