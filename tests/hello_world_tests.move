#[test_only]
module hello_world::greeting_tests {
    use sui::test_scenario::{Self as test, next_tx, ctx};
    use hello_world::greeting::{Self, HelloWorldObject};
    use std::string;

    const USER: address = @0xA;
    const ANOTHER_USER: address = @0xB;

    #[test]
    fun test_create_default_greeting() {
        let mut scenario = test::begin(USER);
        
        // Create default greeting
        {
            greeting::new(ctx(&mut scenario));
        };
        
        // Verify the greeting was created with correct text
        next_tx(&mut scenario, USER);
        {
            let hello_obj = test::take_from_sender<HelloWorldObject>(&scenario);
            
            let text = greeting::get_text(&hello_obj);
            assert!(text == string::utf8(b"Hello World!"), 0);
            
            test::return_to_sender(&scenario, hello_obj);
        };
        
        test::end(scenario);
    }

    #[test]
    fun test_create_custom_greeting() {
        let mut scenario = test::begin(USER);
        
        // Create custom greeting
        {
            greeting::create_custom_greeting(b"Hello, Sui Move!", ctx(&mut scenario));
        };
        
        // Verify custom text
        next_tx(&mut scenario, USER);
        {
            let hello_obj = test::take_from_sender<HelloWorldObject>(&scenario);
            
            let text = greeting::get_text(&hello_obj);
            assert!(text == string::utf8(b"Hello, Sui Move!"), 0);
            
            test::return_to_sender(&scenario, hello_obj);
        };
        
        test::end(scenario);
    }

    #[test]
    fun test_update_greeting() {
        let mut scenario = test::begin(USER);
        
        // Create greeting
        {
            greeting::new(ctx(&mut scenario));
        };
        
        // Update the text
        next_tx(&mut scenario, USER);
        {
            let mut hello_obj = test::take_from_sender<HelloWorldObject>(&scenario);
            
            // Initial text should be "Hello World!"
            assert!(greeting::get_text(&hello_obj) == string::utf8(b"Hello World!"), 0);
            
            // Update to new text
            greeting::update_text(&mut hello_obj, b"Updated greeting!");
            
            // Verify update
            assert!(greeting::get_text(&hello_obj) == string::utf8(b"Updated greeting!"), 1);
            
            test::return_to_sender(&scenario, hello_obj);
        };
        
        test::end(scenario);
    }

    #[test]
    fun test_multiple_greetings() {
        let mut scenario = test::begin(USER);
        
        // Create first greeting
        {
            greeting::new(ctx(&mut scenario));
        };
        
        // Create second custom greeting
        next_tx(&mut scenario, USER);
        {
            greeting::create_custom_greeting(b"Second greeting!", ctx(&mut scenario));
        };
        
        // Both objects should exist for the user
        next_tx(&mut scenario, USER);
        {
            let ids = test::ids_for_sender<HelloWorldObject>(&scenario);
            assert!(ids.length() == 2, 0); // User should have 2 greeting objects
        };
        
        test::end(scenario);
    }

    #[test]
    fun test_transfer_greeting() {
        let mut scenario = test::begin(USER);
        
        // USER creates greeting
        {
            greeting::new(ctx(&mut scenario));
        };
        
        // USER transfers to ANOTHER_USER
        next_tx(&mut scenario, USER);
        {
            let hello_obj = test::take_from_sender<HelloWorldObject>(&scenario);
            transfer::public_transfer(hello_obj, ANOTHER_USER);
        };
        
        // ANOTHER_USER receives and verifies
        next_tx(&mut scenario, ANOTHER_USER);
        {
            let hello_obj = test::take_from_sender<HelloWorldObject>(&scenario);
            assert!(greeting::get_text(&hello_obj) == string::utf8(b"Hello World!"), 0);
            test::return_to_sender(&scenario, hello_obj);
        };
        
        test::end(scenario);
    }

    #[test]
    fun test_empty_custom_message() {
        let mut scenario = test::begin(USER);
        
        // Create greeting with empty message
        {
            greeting::create_custom_greeting(b"", ctx(&mut scenario));
        };
        
        // Verify empty text
        next_tx(&mut scenario, USER);
        {
            let hello_obj = test::take_from_sender<HelloWorldObject>(&scenario);
            assert!(greeting::get_text(&hello_obj) == string::utf8(b""), 0);
            test::return_to_sender(&scenario, hello_obj);
        };
        
        test::end(scenario);
    }

    #[test]
    fun test_long_greeting_message() {
        let mut scenario = test::begin(USER);
        
        // Create greeting with long message
        {
            greeting::create_custom_greeting(
                b"This is a very long greeting message to test if the contract handles longer strings properly!",
                ctx(&mut scenario)
            );
        };
        
        // Verify long text
        next_tx(&mut scenario, USER);
        {
            let hello_obj = test::take_from_sender<HelloWorldObject>(&scenario);
            let expected = string::utf8(b"This is a very long greeting message to test if the contract handles longer strings properly!");
            assert!(greeting::get_text(&hello_obj) == expected, 0);
            test::return_to_sender(&scenario, hello_obj);
        };
        
        test::end(scenario);
    }
}
