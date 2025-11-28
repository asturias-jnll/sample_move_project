module hello_world::greeting {
    use std::string::{Self, String};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// A Hello World object that contains a greeting message
    public struct HelloWorldObject has key, store {
        id: UID,
        /// The greeting text
        text: String,
    }

    /// Event emitted when a greeting is created
    public struct GreetingCreated has copy, drop {
        object_id: ID,
        text: String,
    }

    /// Create a new Hello World object with default message
    public entry fun new(ctx: &mut TxContext) {
        let hello_world = HelloWorldObject {
            id: object::new(ctx),
            text: string::utf8(b"Hello World!"),
        };

        sui::event::emit(GreetingCreated {
            object_id: object::id(&hello_world),
            text: hello_world.text,
        });

        transfer::public_transfer(hello_world, tx_context::sender(ctx));
    }

    /// Create a custom greeting object
    public entry fun create_custom_greeting(message: vector<u8>, ctx: &mut TxContext) {
        let greeting = HelloWorldObject {
            id: object::new(ctx),
            text: string::utf8(message),
        };

        sui::event::emit(GreetingCreated {
            object_id: object::id(&greeting),
            text: greeting.text,
        });

        transfer::public_transfer(greeting, tx_context::sender(ctx));
    }

    /// Update the greeting text
    public entry fun update_text(obj: &mut HelloWorldObject, new_text: vector<u8>) {
        obj.text = string::utf8(new_text);
    }

    /// Get the greeting text (read-only)
    public fun get_text(obj: &HelloWorldObject): String {
        obj.text
    }
}
