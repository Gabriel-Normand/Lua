--[[
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA. 
--]] --
function descriptor()
    return {
        title = "Load from folder",
        version = "1.0",
        author = "Gabriel Normand <https://github.com/Gabriel-Normand>",
        description = "Loads all videos from the same folder as the current video into the playlist"
    }
end

function activate()
    vlc.msg.dbg("[Load from folder] Activated")
    item = vlc.item or vlc.input.item()
    if item == nil then
        vlc.msg.err("[Load from folder] No item found")
        return
    end
    find_files(item)
end

function deactivate()
    vlc.msg.dbg("[Load from folder] Deactivated")
end

function find_files(item)
    -- Get the directory path up to the last / and remove "file:///"
    local path = vlc.strings.decode_uri(string.gsub(string.match(item:uri(), "(.*/)"), "^file:///", ""))

    -- Get the filename after the last /
    local current_video = vlc.strings.decode_uri(string.match(item:uri(), "/([^/]+)$"))

    vlc.msg.dbg("[Load from folder] Loading path: " .. path)
    vlc.msg.dbg("[Load from folder] Target file: " .. current_video)

    -- Enqueue directory contents
    local dir = vlc.io.readdir(path)
    for _, file in pairs(dir) do
        if file:match("%.mp4$") or file:match("%.mkv$") or file:match("%.avi$") then
            local new_item = {}
            new_item.path = "file:///" .. path .. file
            new_item.name = file
            if file ~= current_video then
                vlc.playlist.enqueue({new_item})
            else -- if the file is the same as the one currently playing, replace it

                -- Attempts to save the current position or time and restore it after the new video is loaded
                -- local current_position = vlc.player.item().get_position()
                -- local current_time = vlc.var.get(vlc.object.input(), "time")

                vlc.playlist.delete(vlc.playlist.current())
                vlc.playlist.add({new_item})

                -- vlc.var.set(vlc.object.input(), "time", current_time)
                -- vlc.player.item().seek_by_pos_absolute(current_position)
            end
        end
    end
    vlc.deactivate()
end
