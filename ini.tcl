# ini manage
# 2007-09-06

proc readini {file section item} {
  set file [open $file r]
  while {![eof $file]} {
    gets $file string
    if {$string == "\[$section\]"} {
      while {![eof $file]} {
        gets $file string
        if {[string match "\\\[*\\\]" $string]} { close $file; return }
        set string [split $string =]
        if {$item == [lindex $string 0]} { close $file; return "[join [lrange $string 1 end] "="]" }
      }
    }
  }
  close $file
  return
}
proc ini {file section {item ""}} {
  set file [open $file r]
  if {[string is integer $section]} {
    if {$section == 0} {
      #obter o numero total de sectionos
      set count 0
      while {![eof $file]} {
        gets $file string
        if {[string match "\\\[*\\\]" $string]} { incr count }
      }
      close $file
      return $count
      } else {
      #obter o sectiono na posição $section
      set count 0
      while {![eof $file]} {
        gets $file string
        if {[string match "\\\[*\\\]" $string]} {
          incr count
          if {$count == $section} { close $file; return "[regsub "^\\\[(.+)\\\]$" "$string" "\\1"]" }
        }
      }
      close $file
      return
    }
    } else {
    if {$item == ""} {
      #obter a posição do sectiono $section
      set count 0
      while {![eof $file]} {
        gets $file string
        if {[string match "\\\[*\\\]" $string]} {
          incr count
          if {$string == "\[$section\]"} { close $file; return $count }
        }
      }
      close $file
      return 0
      } else {
      if {[string is integer $item]} {
        if {$item == 0} {
          #obter o numero total de chaves do sectiono $section
          while {![eof $file]} {
            gets $file string
            if {$string == "\[$section\]"} {
              set count 0
              while {![eof $file]} {
                gets $file string
                if {[string match "\\\[*\\\]" $string]} { close $file; return $count }
                if {[string match "?*=*" $string]} { incr count }
              }
              close $file
              return $count
            }
          }
          } else {
          #obter a chave na posição $item do sectiono $section
          while {![eof $file]} {
            gets $file string
            if {$string == "\[$section\]"} {
              set count 0
              while {![eof $file]} {
                gets $file string
                if {[string match "\\\[*\\\]" $string]} { close $file; return }
                if {[string match "?*=*" $string]} { 
                  incr count
                  if {$count == $item} {
                    set string [split $string =]
                    close $file
                    return "[lindex $string 0]"
                  }
                }
              }
              close $file
              return
            }
          }
        }
        } else {
        #obter a posição da chave $item do sectiono $section
        while {![eof $file]} {
          gets $file string
          if {$string == "\[$section\]"} {
            set count 0
            while {![eof $file]} {
              gets $file string
              if {[string "\\\[*\\\]" $string]} { close $file; return 0 }
              if {[string "?*=*" $string]} {
                incr count
                set string [split $string =]
                if {[lindex $string 0] == $item} { close $file; return $count }
              }
            }
            close $file
            return 0
          }
        }
      }
    }
  }
}
proc writeini {filename section item value} {
  #ler o ficheiro e gravalo num array
  if {[file exists $filename]} {
    set file [open $filename r]
    set cursection ""
    while {![eof $file]} {
      gets $file string
      if {[string match "\\\[*\\\]" $string]} {
        set cursection "[regsub "^\\\[(.+)\\\]$" "$string" "\\1"]"
        set sections($cursection) ""
        } elseif {[string match "*=*" $string]} {
        set string [split $string =]
        set curitem [lindex $string 0]
        set sections($cursection) [linsert $sections($cursection) end "$curitem"]
        set values($cursection,$curitem) "[join [lrange $string 1 end] "="]"
      }
    }
    close $file
  }
  #gravar o novo valor no array
  if {![info exists sections($section)]} { set sections($section) "$item" }
  if {[lsearch -exact $sections($section) "$item"] == -1} { set sections($section) [linsert $sections($section) end "$item"] }
  set values($section,$item) $value
  #escrever o novo array no ficheiro
  set file [open $filename w]
  foreach {section items} [array get sections] {
    puts -nonewline $file "\[$section\]\r\n"
    foreach {item} $items {
      puts -nonewline $file "$item=$values($section,$item)\r\n"
    }
  }
  close $file
}
proc remini {file section {item ""}} {

}