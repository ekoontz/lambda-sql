# lambda-sql : using closures to compose SQL statements.
# Eugene Koontz <ekoontz@hiro-tan.org>
# Licensed under the GPL version 3.
#
# Note: uses ruby 1.8 "lambda" syntax (not 1.9 "->" syntax)
#

join = lambda{|type,join_table,c1,c2|
  type.upcase + " JOIN " + join_table + " ON " + c1 + "=" + c2
}

select = lambda{|select,table,type,join_table,c1,c2|
  lambda{|other_type,other_join_table,other_c1,other_c2|
    "SELECT " + select + " " +
     " FROM " + table + " " +
    type.upcase + " JOIN " + join_table + " ON " + c1 + "=" + c2 + " " +
    join.call(other_type,other_join_table,other_c1,other_c2)
  }
}

select_no_join = lambda{|select,table,type,join_table,c1,c2|
  if (type)
    lambda{|other_type,other_join_table,other_c1,other_c2|
      "SELECT " + select + " " +
      " FROM " + table + " " +
      type.upcase 
    }
  else
    "SELECT " + select + " " +
      " FROM " + table + " "
  end
}

(select.
 call('s.name AS station_a,b_stat.name AS station_b',
      'station s',
      'inner','adjacent a','s.abbr','a.station_a')).
  call('inner','station b_stat','b_stat.abbr','a.station_b')


(select_no_join.
 call('s.name AS station_a,b_stat.name AS station_b','station s','inner').
  call('inner','adjacent a','s.abbr','a.station_a')).
    call('inner','station b_stat','b_stat.abbr','a.station_b')



