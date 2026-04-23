----- || SERVICES || -----

local cloneref = (cloneref or function(instance: any) return instance end);
local HttpService = cloneref(game:GetService("HttpService"));

----- || LIBRARY || -----

local WebhookService, Methods, webhooksDict = {}, {}, {};

WebhookService.__index = WebhookService; Methods.__index = Methods;
WebhookService.Presets = loadstring(game:HttpGet("https://raw.githubusercontent.com/00lxh/roblox-webhooks/refs/heads/main/presets.lua"))();

local Janitor = loadstring(game:HttpGet("https://raw.githubusercontent.com/00lxh/roblox-webhooks/refs/heads/main/packages/Janitor.lua"))();
local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/00lxh/roblox-webhooks/refs/heads/main/packages/Signal.lua"))();

----- || METHODS || -----

function Methods:SendWebhook(data)

	local __s, __d = pcall(function()
		
		local url = data._url;
		data._url = nil;

		return request({

			Url = tostring(url); Method = "POST";
			Headers = { ["Content-Type"] = "application/json"; };

			Body = HttpService:JSONEncode(data);
		});
	end);

	return (not __d or not __d.Success and error(__d and __d.StatusMessage or "Unknown error while sending the webhook")) or __d;
end;

function Methods:IsString(str: string)
	return typeof(str) == "string" and str:match("^%s*(.-)%s*$") ~= "";
end;

----- || CALLBACKS || -----

function WebhookService.new()

	local self = setmetatable({}, WebhookService);
	self.preset = "none";
	
	local janitor = Janitor.new();
	self.janitor = janitor;

	local webhookUID = HttpService:GenerateGUID(false);
	webhooksDict[webhookUID] = self;

	janitor:add(function() webhooksDict[webhookUID] = nil; end);
	self.UID = webhookUID;

	self.bindedEvents = {};
	self.OnChanged = janitor:add(Signal.new());

	self.OnMessageSend = janitor:add(Signal.new());
	self.OnEmbedSend = janitor:add(Signal.new());

	return self;
end;

function WebhookService:SetURL(str: string)
	
	assert(not self._destroyed, "This webhook is not longer valid");
	assert(str, "Argument #1 missing or nil");
	
	assert(typeof(str) == "string", 'Invalid argument #1 to "SetURL" (string expected, got ' .. typeof(str) .. ')');
	assert(Methods:IsString(str), 'Invalid argument #1 to "SetURL" (invalid string)');

	self._url = str:gsub("discord.com", "webhook.lewisakura.moe");
	return self;
end;

function WebhookService:SetCustomProxy(str: string)
	
	assert(not self._destroyed, "This webhook is not longer valid");
	assert(str, "Argument #1 missing or nil");

	assert(typeof(str) == "string", 'Invalid argument #1 to "SetCustomProxy" (string expected, got ' .. typeof(str) .. ')');
	assert(Methods:IsString(str), 'Invalid argument #1 to "SetCustomProxy" (invalid string)');
	
	self.custom_proxy = str;

	self._url = self._url:gsub("webhook.lewisakura.moe", self.custom_proxy);
	self._url = self._url:gsub("discord.com", self.custom_proxy);

	self.OnChanged:Fire("Proxy", "ProxyURL", str);
	return self;
end;

function WebhookService:SetPreset(str: string)
	
	assert(not self._destroyed, "This webhook is not longer valid");
	assert(str, "Argument #1 missing or nil");

	assert(typeof(str) == "string", 'Invalid argument #1 to "SetPreset" (string expected, got ' .. typeof(str) .. ')');
	assert(Methods:IsString(str), 'Invalid argument #1 to "SetPreset" (invalid string)');

	self.preset = str;
	self.OnChanged:Fire("Appearance", "Preset", self.preset);

	return self;
end;

function WebhookService:SetAvatar(data: table)
	
	assert(not self._destroyed, "This webhook is not longer valid");

	assert(data, "Argument #1 missing or nil");
	assert(typeof(data) == "table", 'Invalid argument #1 to "SetAvatar" (table expected, got ' .. typeof(data) .. ')');
	
	assert(data.username, "Data argument #1 missing or nil");
	
	assert(typeof(data.username) == "string", 'Invalid argument #1 to "SetAvatar" (string expected, got ' .. typeof(data.username) .. ')');
	assert(Methods:IsString(data.username), 'Invalid argument #1 to "SetAvatar" (invalid string)');
	
	if data.avatar_url then
		
		assert(typeof(data.avatar_url) == "string", 'Invalid argument #2 to "SetAvatar" (string expected, got ' .. typeof(data.avatar_url) .. ')');
		assert(Methods:IsString(data.avatar_url), 'Invalid argument #2 to "SetAvatar" (invalid string)');
	end;
	
	self.username = data.username;
	self.OnChanged:Fire("Appearance", "Username", self.username);

	self.avatar_url = data.avatar_url or "";
	self.OnChanged:Fire("Appearance", "Avatar", self.avatar_url);

	return self;
end;

function WebhookService:SendMessage(str: string)
	
	assert(not self._destroyed, "This webhook is not longer valid");

	assert(self._url, "Webhook url is missing or nil");
	assert(str, "Argument #1 missing or nil");

	assert(typeof(str) == "string", 'Invalid argument #1 to "SendMessage" (string expected, got ' .. typeof(str) .. ')');
	assert(Methods:IsString(str), 'Invalid argument #1 to "SendMessage" (invalid string)');

	local data = {
		_url = self._url; content = str;
	};

	if Methods:IsString(self.username) then data.username = self.username; end;
	if Methods:IsString(self.avatar_url) then data.avatar_url = self.avatar_url; end;

	Methods:SendWebhook(data);
	self.OnMessageSend:Fire(data);

	return self;
end;

function WebhookService:SendEmbed(options: any)
	
	assert(not self._destroyed, "This webhook is not longer valid");
	
	assert(self._url, "Webhook url is missing or nil");
	assert(options, "Argument #1 missing or nil");
	
	if typeof(options) ~= "table" then
		options = { description = tostring(options); };
	end;
	
	if self.preset ~= "none" then

		local data = {
			_url = self._url; embeds = { typeof(self.preset) == "function" and self.preset(table.unpack(options)) or self.preset };
		};

		Methods:SendWebhook(data);
		self.OnEmbedSend:Fire(data.embeds[1]);

		return self;
	end;
	
	assert(typeof(options) == "table", 'Invalid argument #1 to "SendEmbed" (table expected, got ' .. typeof(options) .. ')');
	--assert(Methods:IsString(options.description), 'Invalid argument #1 to "SendEmbed" (invalid string)');
	
	local data = { _url = self._url; embeds = {{
		
		author = options.author or nil;

		title = options.title or " "; description = options.description or " ";
		color = options.color or tonumber(0xFFFAFA);

		image = {
			url = options.image_url or "";
		},

		thumbnail = {
			url = options.thumbnail_url or "";
		};

		fields = options.fields or {};
		
		timestamp = options.timestamp or nil;
		footer = options.footer or nil;
	}}};
	
	if Methods:IsString(self.username) then data.username = self.username; end;
	if Methods:IsString(self.avatar_url) then data.avatar_url = self.avatar_url; end;
	
	if options.buttons and typeof(options.buttons) == "table" then data.components = {{ type = 1; components = options.buttons; }}; end;
	
	Methods:SendWebhook(data);
	self.OnEmbedSend:Fire(data.embeds[1]);

	return self;
end;

function WebhookService:AddLinkButton(str: string, url: string)
	
	assert(not self._destroyed, "This webhook is not longer valid");
	
	assert(str, "Argument #1 missing or nil");
	assert(url, "Argument #2 missing or nil");
	
	assert(typeof(str) == "string", 'Invalid argument #1 to "AddLinkButton" (string expected, got ' .. typeof(str) .. ')');
	assert(Methods:IsString(str), 'Invalid argument #1 to "AddLinkButton" (invalid string)');
	
	assert(typeof(url) == "string", 'Invalid argument #2 to "AddLinkButton" (string expected, got ' .. typeof(url) .. ')');
	assert(Methods:IsString(url), 'Invalid argument #2 to "AddLinkButton" (invalid string)');

	return { type = 2; style = 5; label = str; url = url; };
end;

function WebhookService:BindEvent(event_name: string, __callback)
	
	assert(not self._destroyed, "This webhook is not longer valid");
	
	assert(event_name, "Argument #1 missing or nil");
	assert(__callback, "Argument #2 missing or nil");

	assert(typeof(event_name) == "string", 'Invalid argument #1 to "BindEvent" (string expected, got ' .. typeof(event_name) .. ')');
	assert(Methods:IsString(event_name), 'Invalid argument #1 to "BindEvent" (invalid string)');

	local bindable_event = self[event_name];
	assert(bindable_event and typeof(bindable_event) == "table" and bindable_event.Connect, 'Invalid argument #1 to "BindEvent" (invalid event type)');
	
	assert(typeof(__callback) == "function", 'Invalid argument #2 to "BindEvent" (function expected, got ' .. typeof(__callback) .. ')');

	self.bindedEvents[event_name] = bindable_event:Connect(function(...)
		__callback(...);
	end);

	return self;
end;

function WebhookService:UnbindEvent(event_name: string)
	
	assert(not self._destroyed, "This webhook is not longer valid");
	assert(event_name, "Argument #1 missing or nil");

	assert(typeof(event_name) == "string", 'Invalid argument #1 to "UnbindEvent" (string expected, got ' .. typeof(event_name) .. ')');
	assert(Methods:IsString(event_name), 'Invalid argument #1 to "UnbindEvent" (invalid string)');

	local bindable_event = self.bindedEvents[event_name];
	if not bindable_event then return self end;

	bindable_event:Disconnect();
	self.bindedEvents[event_name] = nil;
	
	return self;
end;

function WebhookService:Destroy()

	if self._destroyed then return; end;
	self._destroyed = true;
	
	for name, connection in pairs(self.bindedEvents) do
		
		if connection and connection.Disconnect then connection:Disconnect(); end;
		self.bindedEvents[name] = nil;
	end;
	
	if self.janitor then self.janitor:Clean(); end;
	
	for uid, instance in pairs(webhooksDict) do
		if instance == self then webhooksDict[uid] = nil; break; end;
	end;
	
	for k in pairs(self) do
		self[k] = nil;
	end;

	setmetatable(self, nil);
end;

function WebhookService:GetWebhook()
	return self;
end;

----- || RETURN || -----

return WebhookService;
