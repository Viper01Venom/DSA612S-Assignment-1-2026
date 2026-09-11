

type Task record {|
    string taskId;
    string description;
|};

type WorkOrder record {|
    string orderId;
    string status;          
    string description;
    Task[] tasks;
|};

type Schedule record {|
    string scheduleId;
    string 'type;           
    string dueDate;         
    string description;
|};

type Component record {|
    string compId;
    string name;
    string description;
|};

type LoanRecord record {|
    string loanId;
    string borrower;
    string loanDate;
    string returnDate;
|};

type BookingRecord record {|
    string bookingId;
    string bookedBy;
    string date;
    string startTime;
    string endTime;
    string purpose;
|};

type Asset record {|
    string assetTag;        
    string name;
    string description;
    string institution;
    string site;
    string status;          
    string dateAcquired;    
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
|};

type Institution record {|
    string name;
    string abbreviation;
    string[] sites;
|};

type LoanRequest record {|
    string borrower;
    string returnDate;
|};

type BookingRequest record {|
    string bookedBy;
    string date;
    string startTime;
    string endTime;
    string purpose;
|};

type ErrorResponse record {|
    string message;
    int code;
|};

type SuccessResponse record {|
    string message;
|};
