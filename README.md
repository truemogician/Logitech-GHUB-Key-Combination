# **:sparkles:Key Combination Framework for Logitech GHUB:sparkles:**
## **:star2:Introduction:star2:**
+ ### **What is it :question:**
  It is a lua script that builds a framework for Logitech GHUB to manage more complated key combination events than G-Shift provided by GUB itself.
+ ### **What's it used for :question:**
  Extend the functionality of Logi mouses. With this framework, users can easily assign keyboard or macro mappings to all kinds of mouse button combinations. The number of keys isn't the limit, as long as your fingers could reach them at the same time :grin:.
+ ### **How to use it :question:**
  1. Download **key combination.lua** from the latest release  
  2. Append a few lua code to register events and add custom handlers
  3. Open GHUB and add a new profile for your target application
  4. Enter the new profile, switch to "Assignments" tab and disable the buttons that you'll register in the script
  5. Create a new script through GHUB
  6. Copy and paste the framework with your own code into the GHUB script editor and save it
  7. Enjoy the powerful mouse
  + Note that if your combination involves primary key and thus you disable it in the new profile, make sure you have alternative way, like using touch board, to do a primary click. Otherwise it's very likely that you lost control of your computer, since most users are not familiar with pure keyboard control.
+ ### **How to test or debug my assignment :question:**
  Obviously, the simplest way is to activate your script in a profile and operate your mouse. But in case some inappropriate assignment might lead to terrible consequence, it's recommended to test the framework using the [test framework](src/test/test%20framework.lua) if you are familiar with lua.  
  Refer to [example.lua](src/test/example.lua) for usage. It's recommended to write test operations in [operations.txt](src/test/operations.txt) like *example.lua*, reading from file makes it possible to use debugger.
## **:star2:Documentation:star2:**
+ ### **Terms** :microscope:
  1. ***Physical and functional mouse button***: Physical mouse buttons are the ones on your mouse, you can press them with your hands, and functional mouse buttons are the default action allocated to major mouse buttons by the operating system. For example, your primary button are default binded to primary click action. So in short, physical mouse buttons are real buttons, and functional mouse buttons are actions in the system. We distinguish the concepts here because in GHUB, you're fully able to change the default action of the major buttons like assign primary click to secondary button and secondary click to primary button.  
  2. ***Pressed and released event:*** One combination could trigger two event, pressed and released. When **all** physical buttons in the combination are pressed in order, pressed event fires. Then when **any** pressed buttons are released, released event is triggered.  
  3. ***Leaf combination:*** A leaf combination is one that no other registered combinations hold it as prefix. For example, if you have following combinations in your registry (each numeric character represent a mouse button), **["1", "12", "23", "123"]**, "1" and "12" are not leaf combinations, because "1" is the prefix of "12" and "123", and "12" is the prefix of "123".  
  4. ***Parallel and nested click:*** A significant concept in released-only events. Given a key sequence **{"a", "b"}**, if doing an parallel click, the framework will **press "a", release "a", press "b", and release "b"**; If using nested mode, the framework will **press "a", press "b", release "b", and release "a"**.
+ ### **Standard** :book:
  Due to the principle of the framework, user should follow the standard below to avoid unexpected behavior in advance.  
  1. ***No duplicate buttons in combination*** :x:  
    Obviously, you cannot press a pressed button, thus such event will never be triggered in real application.
  2. ***Don't rgister a combination more than once*** :x:  
    If one combination is registered multiple times, only the latest assignment will be on effect.
  3. ***Register pressed event for leaf combination only*** :x:  
    Any registered pressed events of *non-leaf combination* will be removed to avoid misbehavior.  
  4. ***Register released event only if possible*** :heavy_check_mark:  
    It could be supposed from above that released-only event leaves more possibility, thus if pressing action is not in demand, switch to released-only register methods.
+ ### **Globals** :globe_with_meridians:
  1. #### ***Action***
      A collection of all actions provided by G-series Lua API. The introduction of each action is written as comments, and their function could be easily guessed by its name. Since in most cases users just need to use the wrapped register methods, there's no need to put detailed documentation on this table.
  2. #### ***Button***
      The collection of mouse buttons. In GHUB API, mouse buttons are identified by an integer, which is hard to remember. This collection gives each button a meaningful name, making it easier to register.
  3. #### ***Settings***  
      *Settings.ScreenResolution* defines the current resolution of your screen. Only affect Action.Cursor.  
	    *Settings.MouseModel* define the model of your mouse. It determines the collection of buttons, in other words, the *Button* variable. Currently only "G502Hero" is supported, because that's the only model I have. I'll provide an easy way for users to configure their own model in the future and add some more common models.
  4. #### ***Event***
      The base table used to register events. Users only need to use it in the following sentence  
	    ```lua
	    Event:SomeRegisteringMethod(parameters...)
	    ```  
	    Notice that you must use **":"**, the **colon** instead of **"."**, the **period**, to call registering methods.
  5. #### ***Mouse***
      A collection of mouse functions like primary click and secondary click. Same as *Button*, it's just help you to memorize.
  6. #### ***KeyCombination***
      The core table of the framework. But for users, it's just used for adding custom handlers. It's only for few special behaviors beyond the basic framework, which won't be in need in most cases.   
	    Refer to [example.lua](src/test/example.lua) for implementation details.
+ ### **Registration** :pencil:
  In most cases, all the code you need to write yourself is registering. Here's some most commonly used methods.  
  1. #### ***RegisterBind***
      ```lua
      Event:RegisterBind(combination,sequence,unorderedGroups?)
      ```
      **Functionality:** When *pressed event* fires, the **functional** mouse buttons and keyboard keys binded to it will be pressed sequentially; Accordingly, the related buttons and keys will be released by a reversed sequence when *released event* fires.  
        
      ***combination:*** The sequence of physical mouse buttons to press, or mouse button combination, in short.  
      ***sequence:*** The sequence of functional mouse buttons and keyboard keys binded to the combination of physical mouse buttons above.  
      ***unorderedGroups:*** By default, *combination* is sequential. For example, if you register 12 and press mouse button 2 earlier than 1, which build the sequence 12, the registered actions won't be called. If the order of some buttons in the combination doesn't matter, this parameter is what you need. If the whole combination should be unordered, assign string "all" to this parameter; If it's just a part of the combination, list them here as a table; If multiple parts are unordered separately, list all parts and wrap them as a table here. The folloing examples will better illustrate it.  
        
      ***Examples:***
      ```lua
      Event:RegisterBind(
        { Button.Primary },
        { Mouse.PrimaryClick }
      )
      Event:RegisterBind(
        { Button.SideMiddle, Button.SideBack },
        {"lctrl", "c"},
        "all"
      )
      Event:RegisterBind(
        { Button.SideFront, Button.SideMiddle, Button.SideBack },
        { "lctrl", Mouse.PrimaryClick},
        { Button.SideMiddle, Button.SideBack }
      )
      --string starting with "#" means delay, unit: ms
      Event:RegisterBind(
        { Button.SideMiddle, Button.SideBack, Button.AuxiliaryFront, Button.AuxiliaryBack },
        { Mouse.SecondaryClick, "#100", "t" },
        {
          { Button.SideMiddle, Button.SideBack },
          { Button.AuxiliaryFront, Button.AuxiliaryBack }
        }
      )
      ```
  2. #### ***RegisterReleasedBind***
      ```lua
      Event:RegisterReleasedBind(combination,sequence,unorderedGroups?)
      ```
      **Functionality:** This method registers an released-only event, which means nothing happens at pressed event. The *sequence* will be executed when released event is triggered. Since no pressed event involved, the two different click modes are involved here.    
        
      ***combination:*** Same as above.  
      ***sequence:*** The sequence of functional mouse buttons and keyboard keys. To distinguish parallel and nested modes, we introduce table level here. The first level are treated nestedly, second parallelly, third nestedly again, and so on. Details will be shown in the examples in the end.  
      ***unorderedGroups:*** Same as above.  
        
      ***Examples:***  
      ```lua
      --"a" and "b" will be clicked nestedly
      Event:RegisterReleasedBind(
        { SideFront },
        { "a", "b" }
      )
      --"a" and "b" will be clicked parallelly
      Event:RegisterReleasedBind(
        { SideMiddle },
        { { "a", "b" } }
      )
      --press "a"
      --press "b", release "b"
      --press "c", release "c"
      --press "d"
      --press "e"
      --release "e"
      --release "d"
      --press "f"
      --release "f"
      --release "a"
      Event:RegisterReleasedBind(
        { SideBack },
        { "a", { "b", "c", { "d", "e" } }, "f" }
      )
      ```
  3. #### ***RegisterReleasedMacro***
      ```lua
      Event:RegisterReleasedMacro(combination, macroName, unorderedGroups?)
      ```
      ***Functionality:*** This is also a released-only registration method. The corresponding macro stored in GHUB will be played at released event.  
        
      ***combination:*** Same as above.  
      ***macroName:*** The name of the macro to be played.  
      ***unorderedGroups:*** Same as above.