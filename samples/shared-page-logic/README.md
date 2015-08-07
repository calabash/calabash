# Shared Page Logic Sample
This sample demonstrates how to share logic across platforms using pages. The relevant files are in

 - features/pages
 - features/android/pages
 - features/ios/pages
 
 and the files
 
  - features/step_definitions/login_steps.rb
  - features/support/pages.rb
  
The pages.rb file is responsible for auto loading the various pages as they depend on eachother and we do not know in which order they are loaded.

## Running the sample
Run the sample using

```
bundle install
cucumber -p android
cucumber -p ios
```

Notice how the ouput changes depeding on the platform. 

## Breakdown of the sample
The `SharedLoginPage` has a method `login(username, password)`.

```ruby
class SharedLoginPage < Calabash::Page
  def login(username, password)
    enter_text_in(username_field, username)
    enter_text_in(password_field, password)
    tap(login_button)
  end

  private

  def username_field
    abstract_method!
  end

  def password_field
    abstract_method!
  end

  def login_button
    abstract_method
  end
end
```

It calls `username_field`, `password_field` and `login_button`. As shown, these methods are abstract i.e. a new class has to inherit from `SharedLoginPage` and define them.

The Android login page does this

```ruby
class Android::LoginPage < SharedLoginPage
  include Calabash::Android

  private

  def username_field
    "* marked:'a_username'"
  end

  def password_field
    "* marked:'a_password'"
  end

  def login_button
    "android.widget.Button marked:'login'"
  end
end
```

Notice how `Android::LoginPage` still includes `Calabash::Android`. This is still needed, as they redefine the Calabash methods used in `SharedLoginPage`. Calling
`page(LoginPage)` from our step definitions still simply instantiates the `LoginPage` of the platform (`Android::LoginPage` or `IOS::LoginPage`).
