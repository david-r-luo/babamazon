pragma solidity ^0.4.13;


contract Amazon {

    /* Add a variable called skuCount to track the most recent sku # */
    uint public skuCount = 0;



    /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
         Call this mappings items 
    */

    mapping (uint => Item) public items;

    /* Add a line that creates an enum called State. This should have 4 states
        forSale
        sold
        shipped
        received
    */
    enum State {ForSale, Sold, Shipped, Received}

    /* Create a struct named Item. 
        Here, add a name, sku, price, state, seller, and buyer 
        We've left you to figure out what the appropriate types are, 
        if you need help you can ask around :)
    */
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address seller;
        address buyer;
    }

    /* Create 4 events with the same name as each possible State (see above)
        Each event should accept one argument, the sku*/

    event LogForSale(uint sku);
    event LogSold(uint sku);
    event LogShipped(uint sku);
    event LogReceived(uint sku);


    modifier isOwner (address owner) {if(msg.sender == owner) {_;}}
    // modifier isOwner (address owner) {require(msg.sender == owner); _;}
    modifier paidEnough(uint value) {if (msg.value >= value) {_;}}
    // modifier paidEnough(uint value) {if (msg.value >= value); _;}

    modifier checkValue(uint amount) {_;if (msg.value > amount) {msg.sender.transfer(msg.value - amount);}}


    /* For each of the following modifiers, use what you learned about modifiers
     to give them functionality. For example, the forSale modifier should require 
     that the item with the given sku has the state ForSale. */
    modifier forSale (uint sku) {if (items[sku].state == State.ForSale) {_;}}
    modifier sold (uint sku) {if (items[sku].state == State.Sold) {_;}}
    modifier shipped (uint sku) {if (items[sku].state == State.Shipped) {_;}}
    modifier received (uint sku) {if (items[sku].state == State.Received) {_;}}


    function Amazon() {
        /* Here, set your skuCount to 0. */
        skuCount = 0;
    }

    function addItem(string _name, uint _price) 
        forSale(skuCount)
    {
        skuCount = skuCount + 1;
        items[skuCount] = Item({
            name: _name, 
            sku: skuCount, 
            price: _price, 
            state: State.ForSale, 
            seller: msg.sender, 
            buyer: msg.sender
        });

        LogForSale(skuCount);
    }

    /* Add a keyword so the function can be paid. This function should transfer money
        to the seller, set the buyer as the person who called this transaction, and set the state
        to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale, 
        if the buyer paid enough, and check the value after the function is called to make sure the buyer is
        refunded any excess ether sent. Remember to call the event associated with this function!*/
    function buyItem(uint sku) payable
        forSale(sku)
        paidEnough(items[sku].price)
        checkValue(items[sku].price)
    {
        items[sku].seller.transfer(items[sku].price);
        items[sku].buyer = msg.sender;
        items[sku].state = State.Sold;

        LogSold(sku);

    }

    /* Add 2 modifiers to check if the item is sold already, and that the person calling this function 
    is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
    function shipItem(uint sku) 
        sold(sku)
        isOwner(items[sku].seller)
    {
        items[sku].state = State.Shipped;
        LogShipped(sku);

    }

    /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function 
    is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
    function receiveItem(uint sku) 
        shipped(sku)
        isOwner(items[sku].buyer)
    {
        items[sku].state = State.Received;
        LogReceived(sku);
    }

    /* We have this function completed so we can run tests, just ignore it :) */
    function fetchLast() returns (string name, uint sku, uint price, uint state, address seller, address buyer) {
        name = items[skuCount].name;
        sku = items[skuCount].sku;
        price = items[skuCount].price;
        state = uint(items[skuCount].state);
        seller = items[skuCount].seller;
        buyer = items[skuCount].buyer;
        return (name, sku, price, state, seller, buyer);
    }

}
