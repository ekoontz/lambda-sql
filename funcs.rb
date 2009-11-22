# lambda-sql : using closures to compose SQL statements.
# Eugene Koontz <ekoontz@hiro-tan.org>
# Licensed under the GPL version 3.
#
# Note: uses ruby 1.8 "lambda" syntax (not 1.9 "->" syntax)
#

from = lambda{|select,table|
  "SELECT " + select + " FROM " + table
}

join_with_from = lambda{|type,join_table,c1,c2|
  lambda{|func,select,table|
    func.call(select,table) + 
    " " + type.upcase + " JOIN " + join_table + " ON " + c1 + "=" + c2
  }
}

join_with_join = lambda{|type,join_table,c1,c2|
  lambda{|other_type,other_join_table,other_c1,other_c2|
    type.upcase + " JOIN " + join_table + " ON " + c1 + "=" + c2 + " " +
    join_with_from.call(other_type,other_join_table,other_c1,other_c2).call(from,'s.name,b_stat.name','station s') + " "
  }
}

join_with_from.call('inner','adjacent a','s.abbr','a.station_a').call(from,'s.name,a.station_b','station s')

(join_with_join.call('inner','adjacent a','s.abbr','a.station_a')).call('inner','station b_stat','b_stat.abbr','a.station_b')




