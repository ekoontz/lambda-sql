# lambda-sql : using closures to compose SQL statements.
# Eugene Koontz <ekoontz@hiro-tan.org>
# Licensed under the GPL version 3.
#
# Note: uses ruby 1.8 "lambda" syntax (not 1.9 "->" syntax)
#

select = lambda{|select,table,joins|
  "SELECT " + select + " " +
  " FROM " + table + " " +
  joins
}

join = lambda{|type,table,c1,c2|
  type.upcase + " JOIN " + table + " ON " + c1 + " = " + c2
}
                           


join3_sql = lambda{|select_cols|
  lambda{|table_a,alias_a,
    table_b,alias_b,
    table_c,alias_c|
    lambda{|jc_a1,jc_b1,jc_b2,jc_c2|
      select.call(select_cols,
                  table_a + ' ' + alias_a,
                  join.call('inner',table_b+' '+alias_b,alias_a+'.'+jc_a1,alias_b+'.'+jc_b1) + ' ' +
                  join.call('inner',table_c+' '+alias_c,alias_c+'.'+jc_b2,alias_b+'.'+jc_c2))
    }
  }
}

@table_alias = 'foo'

from_new_sql = join3_sql.call(@table_alias+'.name AS station_a,b_station.name AS station_b').
  call('station',@table_alias,
       'adjacent','adj',
       'station','b_station').call('abbr','station_a','abbr','station_b')


  





