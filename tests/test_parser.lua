-- Mock vim global
_G.vim = {
  api = {
    nvim_buf_get_lines = function(bufnr, start, end_, strict)
      return {
        "# Header 1",
        "Some content",
        "## Header 2",
        "```lua",
        "# This is a comment inside code",
        "```",
        "### Header 3",
      }
    end
  }
}

-- Load parser
package.path = package.path .. ";./lua/?.lua"
local parser = require("atlas.parser")

-- Run test
local entries = parser.parse(1)

-- Assertions
local function assert_eq(a, b, msg)
  if a ~= b then
    error(string.format("Assertion failed: %s (expected %s, got %s)", msg, tostring(b), tostring(a)))
  end
end

print("Running parser tests...")

assert_eq(#entries, 3, "Number of entries")

assert_eq(entries[1].text, "Header 1", "Entry 1 text")
assert_eq(entries[1].level, 1, "Entry 1 level")
assert_eq(entries[1].line, 1, "Entry 1 line")

assert_eq(entries[2].text, "Header 2", "Entry 2 text")
assert_eq(entries[2].level, 2, "Entry 2 level")
assert_eq(entries[2].line, 3, "Entry 2 line")

assert_eq(entries[3].text, "Header 3", "Entry 3 text")
assert_eq(entries[3].level, 3, "Entry 3 level")
-- Line 7 because:
-- 1: # Header 1
-- 2: Some content
-- 3: ## Header 2
-- 4: ```lua
-- 5: # This is a comment inside code
-- 6: ```
-- 7: ### Header 3
assert_eq(entries[3].line, 7, "Entry 3 line")

print("All tests passed!")
