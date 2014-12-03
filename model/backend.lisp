(in-package :postgres-json)

(defun create-base-table (name model-parameters)
  "Create a PostgreSQL table called NAME in *PGJ-SCHEMA*, both symbols.
Configure table columns names, types etc. using MODEL-PARAMETERS.
This is the base table for the model.  Requires an active DB
connection."
  (with-readers (key key-type jdoc jdoc-type) model-parameters
    (run `(:create-table ,(db-name-string name)
           ((,key       :type ,key-type :primary-key t)
            (valid-to   :type timestamptz :default (:type "infinity" timestamptz))
            (valid-from :type timestamptz :default (:transaction-timestamp))
            (,jdoc      :type ,jdoc-type))))))

(defun create-old-table (name model-parameters)
  "Create a PostgreSQL table called NAME in *PGJ-SCHEMA*, both symbols.
Configure table columns names, types etc. using MODEL-PARAMETERS.
This is the 'old' table for the model, which will store non current
rows.  Requires an active DB connection."
  (with-readers (key key-type jdoc jdoc-type) model-parameters
    (run `(:create-table ,(db-name-string name)
           ((,key       :type ,key-type )
            (valid-to   :type timestamptz)
            (valid-from :type timestamptz)
            (,jdoc      :type ,jdoc-type))
           (:primary-key ,key valid-to)))))

(defun create-gin-index (name table model-parameters)
  "Create a PostgreSQL GIN index with NAME on a database table TABLE
in *PGJ-SCHEMA*, all symbols.  Configure table columns names, types
etc. using MODEL-PARAMETERS.  Note that if you use 'jdoc-type of 'json
when creating the tables you cannot then create these indexes --- see
the PostgreSQL documentation.  In fact the option 'jsonb_path_ops' to
the GIN index may be desirable under some circumstances but I have not
yet twisted s-sql to generate such an index declaration (clearly we
could just use a string).  Requires an active DB connection."
  (with-readers (jdoc) model-parameters
    (run `(:create-index ,name :on ,(db-name-string table)
           :using gin :fields ,jdoc))))
