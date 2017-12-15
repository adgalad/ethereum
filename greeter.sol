pragma solidity ^0.4.17;

import "browser/DateTime.sol";

contract MovieEvent is DateTime {
  
  enum TicketType{
      
      PRESOLD,
      SOLD
  }
  
  struct Ticket {
    address owner;
    string  seat;
    TicketType t;
  }
  
  mapping (string => Ticket) tickets; // tickets[owner]
  mapping (uint   => string) index;
  
  uint16  public theaterId;   // ID of the movie theather
  uint    public ticketPrice; // Price of the ticket
  uint    public date;        // Date of the event
  uint    public nTicket;     // Number of tickets per event
  uint    public nSoldTicket; // Number of sold ticket
  address public owner;


  function MovieEvent(uint16 _theaterId,   
                      uint   _ticketPrice,
                      uint   _nTicket,
                      uint   _date
                     ) public
    {
        date        = _date;
        theaterId   = _theaterId;
        ticketPrice = _ticketPrice;
        nTicket     = _nTicket;
        owner       = msg.sender;
    }
    
    function cancelEvent() public {
        uint i;
        require(_now() < date);
        for (i = 1 ; i < nSoldTicket ; i++ ){
            tickets[index[i]].owner.transfer(ticketPrice);
            delete tickets[index[i]];
            delete index[i];
        }
    }
    
    function buyTicket(string seat) public payable {
        buyTicket(seat,TicketType.SOLD);
    }
    
    function buyTicket(string seat, TicketType t) internal {
        assert(nSoldTicket <= nTicket);
        require(msg.value == ticketPrice); // The value sent must be equal to the ticket price 
        require(_now() < date);            // The purchase date must be lesser than the date of the event
        require(msg.sender != owner);      // Movie theater not allowed to buy tickets
        require(tickets[seat].owner == 0); // unsold ticket
        require(nTicket > 1);
        
        Ticket memory ticket = Ticket(msg.sender, seat, t);
        nSoldTicket++;
        tickets[seat] = ticket;
        index[nSoldTicket] = seat;
    }
    
    function prebuyTicket(string seat) public payable {
        buyTicket(seat, TicketType.PRESOLD);
        owner.transfer(msg.value);
    }
    
    function isOwner(string seat) public view returns (bool){
        Ticket storage t = tickets[seat];
        return  t.owner == msg.sender;
    }
    
    function ticketType(string seat) public view returns (TicketType){
        Ticket storage ticket = tickets[seat];
        require(ticket.owner != 0);
        return ticket.t;
    }
    
    function closeEvent() public {
        require(_now() > date);
        uint i;
        for (i = 1 ; i < nSoldTicket ; i++ ){
            // tickets[index[i]].owner.transfer(ticketPrice);
            delete tickets[index[i]];
            delete index[i];
        }
    }
}

contract MovieTheater is DateTime {

  mapping (uint8 => MovieEvent) events;
  mapping (uint8 => bool) busy;
  function MovieTheater() public {

  }

  function createEvent( uint8 theaterId,
                        uint  ticketPrice,
                        uint8 nTicket,
                        uint16 year,
                        uint8 month,
                        uint8 day,
                        uint8 hour,
                        uint8 minute ) 
  public returns (MovieEvent){
    require(!busy[theaterId]);
    uint date = toTimestamp(year, month, day, hour, minute);
    MovieEvent e = new MovieEvent(theaterId, ticketPrice, nTicket, date);
    events[theaterId] = e;
    busy[theaterId] = true;
    return e;
  }
  
}

