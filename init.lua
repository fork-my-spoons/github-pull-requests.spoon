local obj = {}
obj.__index = obj

-- Metadata
obj.name = "GitHub Pull Requests"
obj.version = "1.0"
obj.author = "Pavel Makhov"
obj.homepage = "https://github.com/fork-my-spoons/github-pull-requests.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.indicator = nil
obj.iconPath = hs.spoons.resourcePath("icons")
obj.menu = {}
obj.task = nil

local calendar_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#8e8e8e'}})
local user_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#8e8e8e'}})
local draft_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#ffd60a'}})
local comment_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#8e8e8e'}})
local project_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#8e8e8e'}})


local function show_warning(text)
    hs.notify.new(function() end, {
        autoWithdraw = false,
        title = obj.name,
        informativeText = text
    }):send()
end

--- Converts string representation of date (2020-06-02T11:25:27Z) to date
local function parse_date(date_str)
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)%Z"
    local y, m, d, h, min, sec, _ = date_str:match(pattern)

    return os.time{year = y, month = m, day = d, hour = h, min = min, sec = sec}
end

--- Converts seconds to "time ago" represenation, like '1 hour ago'
local function to_time_ago(seconds)
    local days = seconds / 86400
    if days > 1 then
        days = math.floor(days + 0.5)
        return days .. (days == 1 and ' day' or ' days') .. ' ago'
    end

    local hours = (seconds % 86400) / 3600
    if hours > 1 then
        hours = math.floor(hours + 0.5)
        return hours .. (hours == 1 and ' hour' or ' hours') .. ' ago'
    end

    local minutes = ((seconds % 86400) % 3600) / 60
    if minutes > 1 then
        minutes = math.floor(minutes + 0.5)
        return minutes .. (minutes == 1 and ' minute' or ' minutes') .. ' ago'
    end
end

local function subtitle(text)
    return hs.styledtext.new(text, {color = {hex = '#8e8e8e'}})
end

local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function obj:update_indicator(stdout)
    self.menu = {}

    local current_time = os.time(os.date("!*t"))
    
    local pulls = hs.json.decode(stdout)
    self.indicator:setTitle(#pulls)

    for k, pull in pairs(pulls) do

        local index = string.find(pull.repository_url, "/[^/]*$")
        local repo = string.sub(pull.repository_url, index + 1)

        local pull_title = hs.styledtext.new(pull.title .. '\n')
                .. project_icon .. subtitle(repo .. '   ')
                .. user_icon .. subtitle(pull.user.login .. '\n')
                .. comment_icon .. subtitle(pull.comments .. '   ')
                .. user_icon .. subtitle(#pull.assignees .. '   ')
                .. calendar_icon .. subtitle(to_time_ago(os.difftime(current_time, parse_date(pull.created_at))) .. '   ')

        if pull.draft == true then
            pull_title = draft_icon .. pull_title
        end

        local submenu = {}

        for _, assignee in pairs(pull.assignees) do
            table.insert(submenu, {
                title = assignee.login,
                image = hs.image.imageFromURL(assignee.avatar_url):setSize({w=36,h=36})
            })
        end
        
        table.insert(submenu, {
            title = '-'
        })
        table.insert(submenu, {
            title = 'Assign to me'
        })

        table.insert(self.menu, {
            title = pull_title,
            image = hs.image.imageFromURL(pull.user.avatar_url):setSize({w=36,h=36}),
            fn = function() os.execute('open ' .. pull.html_url) end,
            menu = submenu
        })

    end

    self.indicator:setMenu(self.menu)
end


function obj:init()
    self.indicator = hs.menubar.new()
    self.indicator:setIcon(hs.image.imageFromPath(self.iconPath .. '/git-pull-request.png'):setSize({w=16,h=16}), true)
end


function obj:setup(args)
    self.repos = args.repos
    self.reviewer = args.reviewer
    self.team_reviewer = args.team_reviewer
end


function obj:start()
    local review_query = ''
    if self.reviewer ~= nil then
        review_query = 'review-requested:' .. self.reviewer
    elseif self.team_reviewer ~= nil then
        review_query = 'team-review-requested:' .. self.team_reviewer
    else
        show_warning('Required parameter reviewer or team_reviewer is not set')
        return
    end

    print(review_query)
    self.task = hs.task.new('/usr/local/bin/gh',
        function(exitCode, stdout, stderr)
            if (stderr ~= '') then
                print(stderr)
                show_warning(stderr)
                return
            end

            self:update_indicator(stdout)
        end,
        {'api', "-X", "GET", "search/issues",
        "-f", "q=" .. review_query .. " is:unmerged is:open",
        "-f", "per_page=30", 
        "--jq", "[.items[] | {url,repository_url,title,html_url,comments,assignees,user,created_at,draft}]"}):start()
end

return obj