## We need minimum of trial license for cross cluster replication
curl -XPOST "localhost:9202/_license/start_trial?acknowledge=true&pretty"

## Enable cross cluster replication in follower cluster
curl -X PUT "localhost:9202/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
{
    "persistent": {
        "cluster": {
            "remote": {
                "leader": {
                    "seeds": [
                        "127.0.0.1:9301"
                    ]
                }
            }
        }
    }
}
'

## Check if follower can reach leader and watching changes in leader cluster
curl -XGET localhost:9202/_remote/info?pretty

## Setting in follower cluster to follow index from leader cluster
curl -X PUT "localhost:9202/_ccr/auto_follow/beats?pretty" -H 'Content-Type: application/json' -d'
{
    "remote_cluster": "leader",
    "leader_index_patterns": [
        "testindex*"
    ],
    "follow_index_pattern": "{{leader_index}}-copy"
}
'

## Create index in leader cluster
curl -XPUT localhost:9201/testindex123

## To make follower index as leader, follow these steps
curl -XPOST "localhost:9202/testindex123-copy/_ccr/close?prettty"
curl -XPOST "localhost:9202/testindex123-copy/_ccr/pause_follow?prettty"
curl -XPOST "localhost:9202/testindex123-copy/_ccr/unfollow?prettty"
curl -XPOST "localhost:9202/testindex123-copy/_ccr/_open?prettty"