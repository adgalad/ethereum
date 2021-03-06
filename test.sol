pragma solidity ^0.4.17;

contract DateTime {  
   /*
   *  Date and Time utilities for ethereum contracts
   *
   */
  struct _DateTime {
          uint16 year;
          uint8 month;
          uint8 day;
          uint8 hour;
          uint8 minute;
          uint8 second;
          uint8 weekday;
  }

  uint constant DAY_IN_SECONDS = 86400;
  uint constant YEAR_IN_SECONDS = 31536000;
  uint constant LEAP_YEAR_IN_SECONDS = 31622400;

  uint constant HOUR_IN_SECONDS = 3600;
  uint constant MINUTE_IN_SECONDS = 60;

  uint16 constant ORIGIN_YEAR = 1970;

  function isLeapYear(uint16 year) internal pure returns (bool) {
    if (year % 4 != 0) {
      return false;
    }
    if (year % 100 != 0) {
      return true;
    }
    if (year % 400 != 0) {
      return false;
    }
    return true;
  }

  function leapYearsBefore(uint year) internal pure returns (uint) {
    year -= 1;
    return year / 4 - year / 100 + year / 400;
  }

  function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
      return 31;
    }
    else if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30;
    }
    else if (isLeapYear(year)) {
      return 29;
    }
    else {
      return 28;
    }
  }

  function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt) {
    uint secondsAccountedFor = 0;
    uint buf;
    uint8 i;

    // Year
    dt.year = getYear(timestamp);
    buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

    secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
    secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

    // Month
    uint secondsInMonth;
    for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                    dt.month = i;
                    break;
            }
            secondsAccountedFor += secondsInMonth;
    }

    // Day
    for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                    dt.day = i;
                    break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
    }

    // Hour
    dt.hour = getHour(timestamp);

    // Minute
    dt.minute = getMinute(timestamp);

    // Second
    dt.second = getSecond(timestamp);

    // Day of week.
    dt.weekday = getWeekday(timestamp);
  }

  function getYear(uint timestamp) internal pure returns (uint16) {
    uint secondsAccountedFor = 0;
    uint16 year;
    uint numLeapYears;

    // Year
    year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
    numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

    secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
    secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

    while (secondsAccountedFor > timestamp) {
      if (isLeapYear(uint16(year - 1))) {
        secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
      }
      else {
        secondsAccountedFor -= YEAR_IN_SECONDS;
      }
      year -= 1;
    }
    return year;
  }

  function getMonth(uint timestamp) internal pure returns (uint8) {
    return parseTimestamp(timestamp).month;
  }

  function getDay(uint timestamp) internal pure returns (uint8) {
    return parseTimestamp(timestamp).day;
  }

  function getHour(uint timestamp) internal pure returns (uint8) {
    return uint8((timestamp / 60 / 60) % 24);
  }

  function getMinute(uint timestamp) internal pure returns (uint8) {
    return uint8((timestamp / 60) % 60);
  }

  function getSecond(uint timestamp) internal pure returns (uint8) {
    return uint8(timestamp % 60);
  }

  function getWeekday(uint timestamp) internal pure returns (uint8) {
    return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
  }

  function toTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint timestamp) {
    return toTimestamp(year, month, day, 0, 0, 0);
  }

  function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal pure returns (uint timestamp) {
    return toTimestamp(year, month, day, hour, 0, 0);
  }

  function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) internal pure returns (uint timestamp) {
    return toTimestamp(year, month, day, hour, minute, 0);
  }

  function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) 
           internal pure returns (uint timestamp) 
  {
    uint16 i;
    // Year
    for (i = ORIGIN_YEAR; i < year; i++) {
      if (isLeapYear(i)) {
        timestamp += LEAP_YEAR_IN_SECONDS;
      }
      else {
        timestamp += YEAR_IN_SECONDS;
      }
    }

    // Month
    uint8[12] memory monthDayCounts;
    monthDayCounts[0] = 31;
    if (isLeapYear(year)) {
      monthDayCounts[1] = 29;
    }
    else {
      monthDayCounts[1] = 28;
    }
    monthDayCounts[2] = 31;
    monthDayCounts[3] = 30;
    monthDayCounts[4] = 31;
    monthDayCounts[5] = 30;
    monthDayCounts[6] = 31;
    monthDayCounts[7] = 31;
    monthDayCounts[8] = 30;
    monthDayCounts[9] = 31;
    monthDayCounts[10] = 30;
    monthDayCounts[11] = 31;

    for (i = 1; i < month; i++) {
      timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
    }

    // Day
    timestamp += DAY_IN_SECONDS * (day - 1);

    // Hour
    timestamp += HOUR_IN_SECONDS * (hour);

    // Minute
    timestamp += MINUTE_IN_SECONDS * (minute);

    // Second
    timestamp += second;

    return timestamp;
  }

  function _now() public view returns (uint){
      return now - 14400; // now minus 4 hours (now is london time)
  }
}


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

