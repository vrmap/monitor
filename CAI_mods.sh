######## start customization

#INTERVAL="1 hour ago"
INTERVAL="10 days ago"
#INTERVAL="yesterday"
#INTERVAL="24 hours ago"
######## end customization

#AREACODE=3600000000 + <see areacodes in actions file>
# you can update areacodes with query
# http://overpass-turbo.eu/s/14bK


AREANAME=$1
case $AREANAME in
  ver)
    AREACODE=3600044107
    ;;
esac


# dates for overpass syntax: 
T0=`date -d "$INTERVAL" '+%Y-%m-%dT%H:%M:%SZ'`
T1=`date                '+%Y-%m-%dT%H:%M:%SZ'`
# dates for parding OSM xml
IERI=`date -d "$INTERVAL" '+%Y-%m-%d'`
OGGI=`date +"%Y-%m-%d"`

# extracting overpass adiff differences
curl -G 'http://overpass-api.de/api/interpreter' --data-urlencode 'data=[out:xml][timeout:300][adiff:"'$T0'","'$T1'"];area('$AREACODE')->.searchArea;(relation["operator"~"^club alpino italiano",i](area.searchArea););(._;>;);out meta geom;' > $AREANAME'.osm'

# no report if no modifications
if  [ `cat $AREANAME.osm | grep action | wc -l` == 0 ]
then
   rm -f $AREANAME.osm
   exit    
fi

echo "<HTML><BODY>Monitor process run on $T1<BR>Changesets since $INTERVAL:<BR>" >> $AREANAME'_changeset.html'
cat $AREANAME'.osm' | grep "$IERI\|$OGGI" | grep changeset | awk ' { match($0, /changeset=\"([0-9]+)\"/, a); print "<A HREF=https://overpass-api.de/achavi/?changeset="a[1]">"a[1]"</A><BR>" }' | sort -u >> $AREANAME'_changeset.html'
echo "</BODY></HTML>" >> $AREANAME'_changeset.html'
