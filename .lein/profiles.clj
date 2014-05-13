{:user
 {:dependencies [[slamhound "1.5.3"]]
  :aliases {"slamhound" ["run" "-m" "slam.hound"]}
  :plugins [[lein-try "0.3.2"]
            [lein-pprint "1.1.1"]
            [lein-ancient "0.4.4" :exclusions [org.clojure/clojure commons-codec org.clojure/data.xml]]
            [lein-bikeshed "0.1.3" :exclusions [org.clojure/clojure]]
            [lein-marginalia "0.7.1" :exclusions [org.clojure/clojure]]
            [lein-immutant "1.2.0"]
            [lein-voom "0.1.0-SNAPSHOT" :exclusions [org.clojure/clojure]]]
  #_:repositories #_{"my.datomic.com" {:url "https://my.datomic.com/repo"
                                   :username "moquist@vlacs.org"
                                   :password "c207a7fc-bae2-4001-9fe5-4346a42970f3"}}}}
