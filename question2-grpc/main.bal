import ballerina/grpc;
import ballerina/uuid;
import ballerina/time;

map<Property> properties = {};
map<User> users = {};
map<Booking> bookings = {};
map<BookPropertyRequest[]> bookingCarts = {};

@grpc:Descriptor {value: ACCOMMODATION_DESC}
service "AccommodationService" on new grpc:Listener(9090) {

    remote function add_property(PropertyRequest value) returns PropertyResponse|error {
        string new_id = uuid:createType1AsString();
        Property new_prop = {
            property_id: new_id,
            host_id: value.host_id,
            name: value.name,
            location: value.location,
            property_type: value.property_type,
            price_per_night: value.price_per_night,
            status: "ACTIVE",
            available: true
        };
        properties[new_id] = new_prop;
        return {property_id: new_id};
    }

    remote function create_users(stream<User, grpc:Error?> clientStream) returns UserStreamResponse|error {
        int count = 0;
        check clientStream.forEach(function(User user) {
            users[user.user_id] = user;
            count += 1;
        });
        return {message: count.toString() + " users created successfully"};
    }

    remote function update_property(UpdatePropertyRequest value) returns UpdatePropertyResponse|error {
        Property prop = value.property;
        if properties.hasKey(prop.property_id) {
            properties[prop.property_id] = prop;
            return {success: true};
        }
        return {success: false};
    }

    remote function remove_property(RemovePropertyRequest value) returns RemovePropertyResponse|error {
        if properties.hasKey(value.property_id) {
            _ = properties.remove(value.property_id);
        }
        Property[] remaining = [];
        foreach var prop in properties {
            remaining.push(prop);
        }
        return {remaining_properties: remaining};
    }

    remote function list_available_properties(ListPropertiesRequest value) returns stream<Property, error?>|error {
        Property[] available = [];
        foreach var prop in properties {
            if prop.available && (value.location == "" || prop.location == value.location) && (value.max_price == 0.0 || prop.price_per_night <= value.max_price) {
                available.push(prop);
            }
        }
        return available.toStream();
    }

    remote function search_property(SearchPropertyRequest value) returns Property|error {
        if properties.hasKey(value.property_id) {
            return properties.get(value.property_id);
        }
        return error("Property not found");
    }

    remote function book_property(BookPropertyRequest value) returns BookPropertyResponse|error {
        string guest_id = value.guest_id;
        if !bookingCarts.hasKey(guest_id) {
            bookingCarts[guest_id] = [];
        }
        BookPropertyRequest[] cart = bookingCarts.get(guest_id);
        cart.push(value);
        bookingCarts[guest_id] = cart;
        return {message: "Property added to booking cart", cart_id: guest_id};
    }

    remote function confirm_booking(ConfirmBookingRequest value) returns ConfirmBookingResponse|error {
        string cart_id = value.cart_id;
        if !bookingCarts.hasKey(cart_id) {
            return error("Booking cart not found");
        }
        BookPropertyRequest[] cart = bookingCarts.get(cart_id);
        if cart.length() == 0 {
            return error("Booking cart is empty");
        }
        BookPropertyRequest req = cart[0]; 
        
        Property prop = properties.get(req.property_id);

        time:Utc checkIn = check time:utcFromString(req.check_in + "T00:00:00Z");
        time:Utc checkOut = check time:utcFromString(req.check_out + "T00:00:00Z");
        
        if checkIn[0] >= checkOut[0] {
            return error("Invalid dates");
        }
        
        int days = (checkOut[0] - checkIn[0]) / 86400;
        float total_cost = <float>days * prop.price_per_night;
        
        string booking_id = uuid:createType1AsString();
        Booking new_booking = {
            booking_id: booking_id,
            property_id: req.property_id,
            guest_id: req.guest_id,
            check_in: req.check_in,
            check_out: req.check_out,
            total_cost: total_cost,
            status: "CONFIRMED"
        };
        
        bookings[booking_id] = new_booking;
        
        _ = bookingCarts.remove(cart_id);
        
        return {booking: new_booking, message: "Booking confirmed"};
    }
}
