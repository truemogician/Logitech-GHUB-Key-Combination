# **:sparkles:Key Combination Framework for Logitech GHUB:sparkles:**
## **:star2:Introduction:star2:**
+ ### **What Is This Framework:question:**
  This is a Lua script that constructs a comprehensive framework for Logitech GHUB, offering advanced key combination functionality that goes beyond what G-Shift can provide.

+ ### **What Purpose Does It Serve:question:**
  The primary goal of this framework is to enhance the capabilities of Logitech mice. With it, users can easily assign keyboard shortcuts and macros to various combinations of mouse buttons. There's virtually no limit to the number of keys you can assign, as long as your fingers can cooperate :grin:.

+ ### **How to Utilize This Framework:question:**
  1. Start by cloning this repository or opt for the express route by downloading **[index.lua](src/index.lua)**.
  2. Write some Lua code to register events and define your own custom actions.
  3. Launch GHUB, create a new profile dedicated to your target application.
  4. Access the new profile, navigate to the "Assignments" tab, and disable the buttons you intend to command through the script. It's a wise precaution to disable all buttons to prevent conflicts.
  5. Create a new script within GHUB.
  6. Simply copy and paste the framework along with your custom code into the GHUB script editor and save your configuration.
  7. Now, revel in the expanded capabilities of your mouse.

  + Should your chosen combination involve the primary mouse button, and you've chosen to disable it within the new profile, ensure you have an alternative means, such as a trusty touchpad, to execute a primary click. This precautionary step can prevent unintended computer sorcery since most users aren't versed in the arcane art of pure keyboard control.

+ ### **How to Test or Debug Your Configurations:question:**
  The most straightforward method is to activate your script within a profile and observe the actions of your mouse. However, due to the potential impact of improper configurations, we recommend testing the framework using the [simulator](src/debug/simulator.lua) if you possess expertise in Lua. For further guidance, refer to an [example](src/example/console-debug.lua). To add a touch of precision to your tests, consider documenting your operations in [operations.txt](src/example/operations.txt). This not only enhances your debugging prowess but also adds an air of scholarly meticulousness to your work.

## **:star2:Documentation:star2:**
+ ### **Glossary** :microscope:
  1. ***Physical and Functional Mouse Buttons***: The physical mouse buttons are the tangible, click-worthy components of your mouse. You can give them the royal treatment with your fingertips. Functional mouse buttons, on the other hand, are the predefined actions assigned to these physical buttons by your operating system. For instance, your primary button defaults to a primary click action. In summary, physical mouse buttons are the real deal, while functional mouse buttons are like the puppeteers behind the scenes. We differentiate between these concepts because in GHUB, you have the power to change the default actions of the major buttons, like making the primary button perform a secondary click and vice versa.

  2. ***Pressed and Released Events***: A single combination can cast two distinct spells: pressed and released events. The pressed event is summoned when **ALL** the physical buttons in the combination are pressed in order. When **ANY** of the pressed buttons are released, the released event is triggered.

  3. ***Leaf Combination***: A leaf combination is one that stands alone, with no other registered combinations preceding it. For example, if your registry holds these combinations (each numeric character representing a mouse button): `["1", "12", "23", "123"]`, `"1"` and `"12"` aren't considered leaf combinations because `"1"` is the prefix of `"12"` and `"123"`, and `"12"` is the prefix of `"123"`. It's a bit like a family tree where some branches are more distant cousins.

  4. ***Sequential and Nested Click***: Here's the scoop on released-only events. When you have a key sequence like `{"a", "b"}`, in sequential mode, the framework will execute a sequence like **press "a", release "a", press "b", and release "b".** In nested mode, it's a bit like Russian nesting dolls: **press "a", press "b", release "b", and release "a".**

+ ### **Best Practices** :book:
  To keep your spellbook clean and avoid unexpected hiccups, it's wise to adhere to the following standards:

  1. ***No Duplicate Buttons in Combination*** :x:  
    Obviously, you can't press a button that's already being pressed - it's like trying to high-five yourself. So, such events are a no-go in the realm of real applications.

  2. ***Avoid Registering the Same Combination Multiple Times*** :x:  
    If you're caught in a time loop and register a combination multiple times, only the latest incantation will take effect. The others shall remain in the mists of history.

  3. ***Exercise Caution with Pressed Events for Non-Leaf Combinations*** :heavy_exclamation_mark:  
    Non-leaf combinations can potentially have pressed events, but beware. Since the framework can't predict if more buttons will join the party when the registered combination is pressed, the pressed event will always ignite, even if you're merely performing a combination that serves as its precursor.

  4. ***Prefer Registering Released-Only Events When Possible*** :heavy_check_mark:  
    As hinted earlier, released-only events are the agile acrobats of the framework. If you don't require the initial button press, they offer more flexibility. So, if you can do without the "press", it's always wiser to go for the "release-only" option.

+ ### **Globals** :globe_with_meridians:
  1. #### ***Action***  
      This is a treasure trove of actions bestowed upon us by the G-series Lua API. Each action comes with its own introduction, conveniently written as comments, and their functions are usually self-evident from their names. In most cases, users can employ the provided register methods without delving into the nitty-gritty details.

  2. #### ***Button***  
      Behold, the esteemed collection of mouse buttons. In the intricate GHUB API, mouse buttons are assigned cryptic integers, making them hard to remember. Here, each button is graced with a name that carries meaning, making registration a breeze. It's like giving your mouse buttons name tags at a party - they become far easier to recognize.

  3. #### ***Settings***  
      Within this domain, there are two paramount settings that command your attention:

      - **Mouse Model**
        Mouse buttons vary across the realm of Logitech mouses. In the labyrinth of GHUB's Lua framework, these buttons are represented by unique integers, a cumbersome practice. To simplify matters, I've generously provided friendly names for some mouse models I have encountered, such as the *G502Hero* and *G604LightSpeed*. If you happen to wield one of these models, a simple adjustment of the right operand in the statement `Button = MouseModel.G604LightSpeed` will suffice. If not, fret not, for I shall reveal a method to craft your own model presets in the future.

      - **Screen Resolution**
        Unless your conjured actions involve the movement of the mouse cursor, this aspect may be safely ignored. To ensure that cursor-related spells work their magic, set your screen resolution as follows:
        ```lua
        Action.Cursor.Resolution = {
          Width = 1920,
          Height = 1080
        }
        ```
        Journey to **Settings > System > Screen > Monitor Resolution** to unveil the secrets of your screen's dimensions, in case such knowledge eludes you.

  4. #### ***Event***
      This is the foundational table employed to inscribe events into the annals of your mouse's existence. Users need only invoke it as follows:
      ```lua
      Event:SomeRegisteringMethod(parameters...)
      ```
      Do take note, it's crucial to employ `:`, the colon, rather than the `.`, the period, when invoking the registering methods. You might find the nuances intriguing; delve into Lua's esoteric texts if you yearn for more wisdom.

  5. #### ***Mouse***
      Just as a compendium aids your memory, this is a compendium of mouse functions such as the primary click and secondary click. Much like training wheels for beginners, it's here to help you remember the basics.

  6. #### ***KeyCombination***
      This is the heart and soul of the framework, a sanctuary for custom handlers. For most users, it's like the hidden treasure chest beyond the known map, reserved for special behaviors that venture beyond the usual. In most cases, it remains untouched, serving as a secret vault that only a select few dare to explore. You'll find more insights into its secrets in the [example](src/example/console-debug.lua).

+ ### **Registration** :pencil:
  In most cases, your journey will primarily revolve around registrations. Here are some of the commonly used methods:

  1. #### ***RegisterBind***
      ```lua
      Event:RegisterBind(combination, sequence, unorderedGroups?)
      ```

      **Functionality:** When the *pressed event* occurs, this method sequentially presses the specified **functional** mouse buttons and keyboard keys corresponding to the physical mouse buttons in the combination. The related buttons and keys are released in a reversed sequence when the *released event* is triggered.

      ***`combination`:*** Refers to the sequence of physical mouse buttons to be pressed, or, in short, the mouse button combination.

      ***`sequence`:*** This indicates the sequence of functional mouse buttons and keyboard keys that are bound to the combination of physical mouse buttons.

      ***`unorderedGroups`:*** By default, the *combination* is expected to be sequential. For example, if you register `"12"` but press mouse button 2 before 1, thereby forming the sequence `"21"`, the registered actions won't be executed. If the order of some buttons in the combination doesn't matter, you can employ this parameter. If the entire combination should be considered unordered, assign the string `"all"` to this parameter. If only a portion of the combination should be unordered, list those portions as a table. If multiple sections of the combination are unordered separately, list all the parts and encapsulate them as a table. For a clearer understanding, refer to the examples provided below.

      ***Examples:***
      ```lua
      Event:RegisterBind(
        Button.Primary,
        Mouse.PrimaryClick
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
      Event:RegisterReleasedBind(combination, sequence, unorderedGroups?)
      ```

      **Functionality:** This method registers a released-only event, meaning no action is performed during the pressed event. The *sequence* will be executed when the released event is triggered. This method offers two different click modes.

      ***`combination`:*** Same as previously described.

      ***`sequence`:*** This denotes the sequence of functional mouse buttons and keyboard keys. To distinguish between sequential and nested modes, a table structure is introduced. The first level operates in a nested manner, the second operates sequentially, and so on. For detailed examples, please refer to the provided demonstrations.

      ***`unorderedGroups`:*** Identical to the earlier explanation.

      ***Examples:***
      ```lua
      -- "a" and "b" will be clicked nestedly
      Event:RegisterReleasedBind(
        Button.SideFront,
        { "a", "b" }
      )
      -- "a" and "b" will be clicked sequentially
      Event:RegisterReleasedBind(
        Button.SideMiddle,
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
        Button.SideBack,
        { "a", { "b", "c", { "d", "e" } }, "f" }
      )
      ```

  3. #### ***RegisterReleasedMacro***
      ```lua
      Event:RegisterReleasedMacro(combination,  macroName, unorderedGroups?)
      ```

      ***Functionality:*** This is also a released-only registration method. It involves playing the corresponding macro stored in GHUB when the released event is triggered.

      ***`combination`:*** Same as previously described.

      ***`macroName`:*** This field requires the name of the macro to be executed.

      ***`unorderedGroups`:*** Identical to the earlier explanation.
