print("RUNNING DISPLAY SERVER");

-- wrap modem
local modem = peripheral.wrap("top");
disp  = peripheral.find("arController");

-- employee table
employees = {};

-- last update time
lastUpdate = 0;

-- listen on service port
modem.open(77);

-- register a function for listening
function listenOnPort(port)
    local event,
          modemSide,
          senderChannel,
          replyChannel,
          message,
          senderDistance = os.pullEvent("modem_message");

    if port == senderChannel then
        return message;
    else
        return listenOnPort(port);
    end
end

-- drawing the UI
function redraw()
    disp.clear();
    
    disp.drawString("VALUED EMPLOYEES", 5, 5, 0xFFFFFF);
    
    local index = 0;
    for k, v in pairs(employees) do
        disp.drawString(k, 5, 20 + index * 20, 0xAAAAAA);
        
        -- progress bar
        disp.fill(5, 30 + index * 20, 105, 32 + index * 20, 0x25632c);
        disp.fill(5, 30 + index * 20, 5 + v[1], 32 + index * 20, 0x3dad49) ;
        
        -- fuel bar
        local fuelPercent = (v[2] / 20000) * 100;
        disp.fill(5, 34 + index * 20, 105, 36 + index * 20, 0x474747 )
        disp.fill(5, 34 + index * 20, 5 + fuelPercent, 36 + index * 20, 0x1c1c1c);
        
        index = index + 1;     
    end
end 

-- stolen from SO
function split (inputstr, sep) if sep == nil then sep = "%s" end local t={} for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end return t end

-- listen on port 77 forever
while true do
    local update = listenOnPort(77);
    local data = split(update, ";");
    
    -- store employee data
    employees[data[1]] = {data[2], data[3]}
    
    -- check if we need to update the UI
    if os.time() - lastUpdate > 0.5 then
        redraw();
        lastUpdate = os.time();
    end
end