# lambda-sql : using closures to compose SQL statements.
# Eugene Koontz <ekoontz@hiro-tan.org>
# Licensed under the GPL version 3.
#
# Note: uses ruby 1.9 "->" syntax (not 1.8 "lambda" syntax)
#
# <library functions>

schematized_where = ->(select,from,where){
  ->(schema){ 
    "SELECT '" + schema + "' AS schema, " + select + 
    "  FROM " + schema + "." + from + 
    " WHERE " + where 
  }
}

from_where = ->(from,where){
  ->(select){ 
    ->(schema){ 
      "SELECT '" + schema + "' AS schema, " + select +
      "  FROM " + schema + "." + from + 
      " WHERE " + where 
    }
  }
}

from = ->(from){
  ->(where) {
    ->(select){ 
      ->(schema){ 
        "SELECT '" + schema + "' AS schema, " + select +
        "  FROM " + schema + "." + from + 
        " WHERE " + where 
      }
    }
  }
}

union2 = ->(schf){
  ->(sch2,sch1){
    schf.call(sch1) + 
    " UNION " + 
    schf.call(sch2) 
  }
}

set_window = ->(query,limit,offset,orderby) {
  query + " ORDER BY " + orderby + " LIMIT " + limit + " OFFSET " + offset 
}

# </library functions>

# <example usages>

kernel = from.
  call(
       "   project " + 
       "INNER JOIN person manager " + 
       "        ON project.manager_id = manager.person_id " +
       "INNER JOIN location " + 
       "        ON location.location_id = project.location_id"
       )

kernel_with_where = kernel.
  call(
       "project.created_on > '2009-08-01'"
       )

kernel_with_select = kernel_with_where.
  call(
       "project_id,project.name,created_on, " + 
       "manager.name, " + 
       "location.street_number || ' ' || location.street AS address"
       )

kernel_union = union2.call(kernel_with_select).
  call("software",
       "finance")

my_query = set_window.call(kernel_union,
                           "20",
                           "10",
                           "created_on DESC")

# </example usages>
  
