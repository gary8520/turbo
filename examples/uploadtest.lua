-- vim: sts=4 sw=4 et si
--- Turbo.lua Parameters example
--
-- Copyright 2013 John Abrahamsen
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local turbo = require "turbo"

local NumericHandler = class("NumericHandler", turbo.web.RequestHandler)

function NumericHandler:get(num)
    -- This handler takes one parameter from the Application class.
    -- The argument must consists of arbitrary length of digits.
    self:write("Numeric resource is: " .. num)
end


local ArgumentsHandler = class("ArgumentsHandler", turbo.web.RequestHandler)

function ArgumentsHandler:get()
    -- This handler takes one GET argument.
    self:write("Argument is: " .. self:get_argument("query"))
end

local function showtable(tab, depth)
    if not depth then depth =0 end
    if depth > 4 then return end
    for k,v in pairs(tab) do
        if type(v) == "table" then
            print(string.rep("\t", depth), k, "...")
            showtable(v, depth +1)
        else
            print( string.rep("\t", depth),k,v)
        end
    end
end

function ArgumentsHandler:post()
    -- This handler takes one POST argument.
    self:write("Argument is: " .. self:get_argument("query").. "\n")
    self:write("file is: " .. self:get_argument("upload"):sub(1,50) .. "\n")
    print("file is",self:get_argument("upload"):sub(1, 50))
    
    print("show self.request")
    --showtable(self.request)
    
    local args = self.request.connection.arguments
    if args then
        print("show args")
        --showtable(args)
        local path = args["upload"][1]["filepath"]
        if path then
            print("path", path)
            os.rename(path, "/tmp/bb.txt")
        end
    end
    --showtable(self)
    --self:finish() 
    return
end

turbo.web.Application({
    {"^/num/(%d*)$", NumericHandler},
    {"^/argument$", ArgumentsHandler}
}):listen(8888, "127.0.0.1", {streaming_multipart_bytes =  3*1024*1024 })
turbo.ioloop.instance():start()
