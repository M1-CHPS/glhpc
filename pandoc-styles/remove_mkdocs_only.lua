-- remove_mkdocs_only.lua
-- Removes divs with class "mkdocs-only" for Pandoc builds

function Div(el)
  for _, class in ipairs(el.classes) do
    if class == "mkdocs-only" then
      return {}  -- remove this div entirely
    end
  end
  return nil  -- leave other divs unchanged
end