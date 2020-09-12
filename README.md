# Laravel Socialite Providers

## 1. Installation

```bash
composer require laravel-fans/socialite-providers
```

## 2. Service Provider

* Remove `Laravel\Socialite\SocialiteServiceProvider` from your `providers[]` array in `config\app.php` if you have added it already.

* Add `\SocialiteProviders\Manager\ServiceProvider::class` to your `providers[]` array in `config\app.php`.

For example:

```php
return [
    'providers' => [
        /*
         * Package Service Providers...
         */
        // remove 'Laravel\Socialite\SocialiteServiceProvider',
        \SocialiteProviders\Manager\ServiceProvider::class,
    ]
];
```

* Note: If you would like to use the Socialite Facade, you need to [install it.](https://github.com/laravel/socialite)

## 3. Event Listener

* Add `SocialiteProviders\Manager\SocialiteWasCalled` event to your `listen[]` array  in `app/Providers/EventServiceProvider`.

* Add your listeners (i.e. the ones from the providers) to the `SocialiteProviders\Manager\SocialiteWasCalled[]` that you just created.

* The listener that you add for this provider is `'LaravelFans\\SocialiteProviders\\Coding\\CodingExtendSocialite@handle',`.

* Note: You do not need to add anything for the built-in socialite providers unless you override them with your own providers.

For example:

```php
use LaravelFans\SocialiteProviders\Coding\CodingExtendSocialite;
use LaravelFans\SocialiteProviders\WeChatWeb\WeChatWebExtendSocialite;
use SocialiteProviders\Manager\SocialiteWasCalled;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
        SocialiteWasCalled::class => [
            // add your listeners (aka providers) here
            CodingExtendSocialite::class,
            WeChatWebExtendSocialite::class,
        ],
    ];
}
```

#### Reference

* [Laravel docs about events](http://laravel.com/docs/events)
* [Laracasts video on events in Laravel 5](https://laracasts.com/lessons/laravel-5-events)

## 4. Configuration setup

You will need to add an entry to the services configuration file so that after config files are cached for usage in production environment (Laravel command `artisan config:cache`) all config is still available.

#### Add to `config/services.php`.

```php
return [
    'coding' => [
        'client_id' => env('CODING_CLIENT_ID'),
        'client_secret' => env('CODING_CLIENT_SECRET'),
        'redirect' => env('CODING_CALLBACK_URL'),
        'guzzle' => [
            'base_uri' => 'https://' . env('CODING_TEAM') . '.coding.net/',
        ],
        'scopes' => preg_split('/,/', env('CODING_SCOPES'), null, PREG_SPLIT_NO_EMPTY), // optional, can not use explode, see vlucas/phpdotenv#175
    ],
];
```

## 5. Usage

* [Laravel docs on configuration](http://laravel.com/docs/master/configuration)

* You should now be able to use it like you would regularly use Socialite (assuming you have the facade installed):

```php
return Socialite::with('coding')->redirect();
```

### Lumen Support

You can use Socialite providers with Lumen.  Just make sure that you have facade support turned on and that you follow the setup directions properly.

**Note:** If you are using this with Lumen, all providers will automatically be stateless since **Lumen** does not keep track of state.

Also, configs cannot be parsed from the `services[]` in Lumen.  You can only set the values in the `.env` file as shown exactly in this document.  If needed, you can
  also override a config (shown below).

### Stateless

* You can set whether or not you want to use the provider as stateless.  Remember that the OAuth provider (Twitter, Tumblr, etc) must support whatever option you choose.

**Note:** If you are using this with Lumen, all providers will automatically be stateless since **Lumen** does not keep track of state.

```php
// to turn off stateless
return Socialite::with('coding')->stateless(false)->redirect();

// to use stateless
return Socialite::with('coding')->stateless()->redirect();
```

### Overriding a config

If you need to override the providers environment or config variables dynamically anywhere in your application, you may use the following:

```php
$clientId = "foo";
$clientSecret = "bar";
$redirectUrl = "http://127.0.0.1:8000/login/coding/callback";
$additionalProviderConfig = [
    // Add additional configuration values here.
    'guzzle' => [
        'base_uri' => 'https://your-team.coding.net/',
    ],
];
$config = new \SocialiteProviders\Manager\Config(
    $clientId,
    $clientSecret,
    $redirectUrl,
    $additionalProviderConfig
);

return Socialite::with('coding')->setConfig($config)->redirect();
```

### Retrieving the Access Token Response Body

Laravel Socialite by default only allows access to the `access_token`.  Which can be accessed
via the `\Laravel\Socialite\User->token` public property.  Sometimes you need access to the whole response body which
may contain items such as a `refresh_token`.

You can get the access token response body, after you called the `user()` method in Socialite, by accessing the property `$user->accessTokenResponseBody`;

```php
$user = Socialite::driver('coding')->user();
$accessTokenResponseBody = $user->accessTokenResponseBody;
```

#### Reference

* [Laravel Socialite Docs](https://github.com/laravel/socialite)
* [CODING OAuth](https://help.coding.net/docs/project/open/oauth.html)

