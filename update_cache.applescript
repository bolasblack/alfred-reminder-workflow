on format_time(currTime as date)
	  set stamp to the time of currTime
	  set h to text -2 thru -1 of ("00" & (stamp div (60 * 60)))
	  set m to text -2 thru -1 of ("00" & (stamp - (60 * 60) * h) div 60)
	  set s to text -2 thru -1 of ("00" & (stamp - ((60 * 60) * h + 60 * m)))
	  return h & ":" & m & ":" & s
end format_time

-- from http://henrysmac.org/blog/2014/1/4/formatting-short-dates-in-applescript.html
on format_date(currTime as date)
	  set y to text -4 thru -1 of ("0000" & year of currTime)
	  set m to text -2 thru -1 of ("00" & (month of currTime as integer))
	  set d to text -2 thru -1 of ("00" & day of currTime)
	  return y & "-" & m & "-" & d
end format_date

on format_datetime(currTime as date)
	  format_date(currTime) & " " & format_time(currTime)
end format_datetime

-- from http://www.macosxautomation.com/applescript/sbrt/sbrt-06.html
on replace_chars(this_text as string, search_string as string, replacement_string as string)
	  set text item delimiters to the search_string
	  set item_list to every text item of this_text
	  set text item delimiters to the replacement_string
	  set this_text to the item_list as string
	  return this_text
end replace_chars




set workflowFolder to do shell script "pwd"
set wlib to load script POSIX file (workflowFolder & "/q_workflow.scpt")
set wf to wlib's new_workflow_with_bundle("org.c4605.reminder")

set output to ""

on null_or_datetime(datetime)
	  if datetime is equal to missing value then
		    return "null"
	  else
		    return "\"" & format_datetime(datetime) of me & "\""
	  end if
end null_or_datetime

on null_or_string(content)
	  if content is equal to missing value then
		    return "null"
	  else
		    return "\"" & replace_chars(content, "\"", "\\\"") of me & "\""
	  end if
end null_or_string

tell application "Reminders"
	  set todolists to every list
	  repeat with i from 1 to length of todolists
		    set todolist to item i of todolists
		    set todos to reminders of todolist
		    set output to output & "{"

		    set output to output & "\"id\": \"" & (id of todolist) & "\", "
		    set output to output & "\"name\": \"" & (name of todolist) & "\", "
		    set output to output & "\"todos\": ["
		    repeat with j from 1 to length of todos
			      set todo to item j of todos
			      set title to replace_chars(name of todo, "\"", "\\\"") of me
			      set output to output & "{"

			      set output to output & "\"id\": \"" & (id of todo) & "\","
			      set output to output & "\"title\": \"" & title & "\","
			      set output to output & "\"body\": " & null_or_string(body of todo) of me & ","
			      set output to output & "\"priority\": " & (priority of todo) & ","
			      set output to output & "\"completed\": " & (completed of todo) & ","
			      set output to output & "\"created_at\": " & null_or_datetime(creation date of todo) of me & ","
			      set output to output & "\"updated_at\": " & null_or_datetime(modification date of todo) of me & ","
			      set output to output & "\"completed_at\": " & null_or_datetime(completion date of todo) of me & ","
			      set output to output & "\"due_date\": " & null_or_datetime(due date of todo) of me & ","
			      set output to output & "\"remind_date\": " & null_or_datetime(remind me date of todo) of me

			      set output to output & "}"
			      if j is not length of todos then
				        set output to output & ", "
			      end if
		    end repeat
		    set output to output & "]"

		    set output to output & "}"
		    if i is not length of todolists then
			      set output to output & ", "
		    end if
	  end repeat
end tell

set output to "[" & output & "]"
wf's write_file(output, "reminder_cache.json")
return
