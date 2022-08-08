# **:sparkles:Key Combination Framework for Logitech GHUB:sparkles:**
## **:star2:Introduction:star2:**
+ ### **What is it :question:**
  It is a lua script that builds a framework for Logitech GHUB to manage more complicated key combination events than the G-Shift provided by GHUB itself.
+ ### **What's it used for :question:**
  Extend the functionality of Logitech mice. With this framework, users can easily assign keyboard or macro mappings to all kinds of mouse button combinations. The number of keys isn't the limit, as long as your fingers could reach them at the same time :grin:.
+ ### **How to use it :question:**
  1. Clone this repository, or simply download **[index.lua](src/index.lua)**  
  2. Append a few lua code to register events and add custom handlers
  3. Open GHUB and add a new profile for your target application
  4. Enter the new profile, switch to "Assignments" tab and disable the buttons that you'll register in the script. It is recommended to disable all the buttons in case of conflict
  5. Create a new script through GHUB
  6. Copy and paste the framework with your own code into the GHUB script editor and save it
  7. Enjoy your enhanced mouse
  + Note that if your combination involves primary key and thus you disable it in the new profile, make sure you have alternative way, like using touchpad, to perform a primary click. Otherwise it's very likely that you lost control of your computer, since most users are not familiar with pure keyboard control.
+ ### **How to test or debug my assignment :question:**
  Obviously, the simplest way is to activate your script in a profile and operate your mouse. But in case some inappropriate assignment might lead to severe consequence, it's recommended to test the framework using the [simulator](src/debug/simulator.lua) if you are familiar with lua.  
  Refer to an [example](src/example/console-debug.lua) for usage. It's recommended to write test operations in [operations.txt](src/example/operations.txt), reading from file makes it possible to use debugger.
## **:star2:Documentation:star2:**
+ ### **Terms** :microscope:
  1. ***Physical and functional mouse button***: Physical mouse buttons are the ones on your mouse, you can press them with your hands, and functional mouse buttons are the default action allocated to major mouse buttons by the operating system. For example, your primary button are default binded to primary click action. So in short, physical mouse buttons are real buttons, and functional mouse buttons are actions in the system. We distinguish the concepts here because in GHUB, you're fully able to change the default action of the major buttons like assign primary click to secondary button and secondary click to primary button.  
  2. ***Pressed and released event:*** One combination could trigger two event, pressed and released. When **all** physical buttons in the combination are pressed in order, pressed event fires. Then when **any** pressed buttons are released, released event is triggered.  
  3. ***Leaf combination:*** A leaf combination is one that no other registered combinations hold it as prefix. For example, if you have following combinations in your registry (each numeric character represent a mouse button), **["1", "12", "23", "123"]**, "1" and "12" are not leaf combinations, because "1" is the prefix of "12" and "123", and "12" is the prefix of "123".  
  4. ***Sequential and nested click:*** A significant concept in released-only events. Given a key sequence **{"a", "b"}**, if doing an sequential click, the framework will **press "a", release "a", press "b", and release "b"**; If using nested mode, the framework will **press "a", press "b", release "b", and release "a"**.
+ ### **Standard** :book:
  Due to the principle of the framework, user should follow the standard below to avoid unexpected behavior in advance.  
  1. ***No duplicate buttons in combination*** :x:  
    Obviously, you cannot press a pressed button, thus such event will never be triggered in real application.
  2. ***Don't rgister a combination more than once*** :x:  
    If one combination is registered multiple times, only the latest assignment will be on effect.
  3. ***Try to avoid registering pressed event for non-leaf combination*** :heavy_exclamation_mark:  
    Non-leaf combinations are possible to have a pressed event, however, since the framework cannot predict whether more buttons will be pressed when the registered combination is pressed, the pressed event will always fire even if you're actually performing a combination that prefix this combination.
  4. ***Register only the released event if possible*** :heavy_check_mark:  
    It could be supposed from above that released-only event leaves more possibility, thus if pressing action is not in demand, switch to released-only register methods.
+ ### **Globals** :globe_with_meridians:
  1. #### ***Action***
      A collection of all actions provided by G-series Lua API. The introduction of each action is written as comments, and their function could be easily guessed by its name. Since in most cases users just need to use the wrapped register methods, there's no need to put detailed documentation on this table.
  2. #### ***Button***
      The collection of mouse buttons. In GHUB API, mouse buttons are identified by an integer, which is hard to remember. This collection gives each button a meaningful name, making it easier to register.
  3. #### ***Settings***  
      Generally, there are 2 settings fields uesrs should care about.  
      - **Mouse model**  
        Mouse buttons varies for different Logitech mouses. In GHUB's Lua framework, mouse buttons are identified by unique integers, making registration unhandy. For convinience, I defined those integers with user-friendly names for some mouse models I have access to, or to say *G502Hero* and *G604LightSpeed* currently speaking.
        If you happened to use one of the models I've provided, simply set the model by changing the right operand of statement `Button = MouseModel.G604LightSpeed`; if not, don't worry, I'll provide a way to create your own model preset in the future.
      - **Screen resolution**  
        You may ignore this part if your actions wouldn't involve mouse cursor.  
        Set your screen resolution in the following statement to make cursor related actions work properly.
        ```lua
        Action.Cursor.Resolution = {
          Width = 1920,
          Height = 1080
        }
        ```
        Go to **Settings > System > Screen > Monitor resolution** to get your scrren resolution, in case you have no idea how.
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
	    Refer to [example](src/example/console-debug.lua) for implementation details.
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
      ***sequence:*** The sequence of functional mouse buttons and keyboard keys. To distinguish sequential and nested modes, we introduce table level here. The first level are treated nestedly, second sequentially, third nestedly again, and so on. Details will be shown in the examples in the end.  
      ***unorderedGroups:*** Same as above.  
        
      ***Examples:***  
      ```lua
      --"a" and "b" will be clicked nestedly
      Event:RegisterReleasedBind(
        { SideFront },
        { "a", "b" }
      )
      --"a" and "b" will be clicked sequentially
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