
local Socket = require("socket").bind('*', 5000)

if not Socket then
	print("Error: Could not bind socket.\n")
	os.exit(0)
end

print(string.format("Listening on %s:%s", Socket:getsockname()))

while true do
	local Client = Socket:accept()
	Client:settimeout(60)

	local Request, Error = Client:receive()

	if not Error then
		local Split = {}

		for Line in Request:gmatch("[^ ]+") do
			table.insert(Split, Line)
		end

		local Type, Url = Split[1], Split[2]

		print("[Request] type: " .. Type .. " url: " .. Url)

		local Directory = "./"

		for File in string.gmatch(Url, "([^/]+)") do
			Directory = Directory .. "/" .. File
		end

		Directory = Directory .. "/index.html"

		local File = io.open(Directory, 'r')	

		if File then
			Client:send(string.format("HTTP/1.1 200 OK\r\nContent-type: text/html\r\n\r\n %s\n", File:read("*all")))

			File:close()
		else
			Client:send("HTTP/1.1 404 Not Found\r\nContent-type: text/html\r\n\r\n <h1>404 Not Found</h1>\n")
		end
	end

	Client:close()
end
