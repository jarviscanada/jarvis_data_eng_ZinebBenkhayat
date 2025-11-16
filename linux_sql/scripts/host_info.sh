#Setup arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#validate arguments
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#parse hardware specification
lscpu_out=`lscpu`
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model="$(echo "$lscpu_out" | grep '^Model name:' | awk '{print substr($0, index($0, $3))}' | xargs)"
cpu_mhz=$( cat /proc/cpuinfo | grep 'cpu MHz' | awk '{print $4}' | uniq)
l2_cache=$(echo "$lscpu_out"  | egrep "^L2 cache:" | awk  '{print $3 * 1024}' | xargs)
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date -u +'%Y-%m-%d %H:%M:%S')

insert_stmt="INSERT INTO host_info  ( hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)
VALUES('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp','$total_mem')";

export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?