from keystoneauth1.identity import v3
from keystoneauth1 import session
from keystoneclient.v3 import client
from magnumclient.client import Client
from magnumclient.v1.clusters_shell import do_cluster_config
import time
import argparse

def connect(username, password):
    auth = v3.Password(auth_url='https://keystone.cern.ch/main/v3',
                       username=username,
                       password=password,
                       project_name='Personal %s' % username,
                       user_domain_id='default',
                       project_domain_id='default'
                       )
    sess = session.Session(auth=auth)

    magnum = Client(session=sess)

    return magnum

def template_id(magnum, name='kubernetes'):
    tmpl_id = [t.uuid for t in magnum.cluster_templates.list()
               if t.name == name]
    if len(tmpl_id) != 1:
        raise ValueError('No template with such name')
    return tmpl_id[0]

def config_cluster(magnum, uuid):
    do_cluster_config(magnum, argparse.Namespace(dir='.', cluster=uuid, force=False))

def create_cluster(magnum, name, keypair, template, nodes):
    template = template if template else 'kubernetes'
    nodes = nodes if nodes else 2

    tmpl_id = template_id(magnum, template)
    uuid = magnum.clusters.create(name=name, cluster_template_id=tmpl_id,
                                  node_count=nodes, keypair=keypair).uuid
    print('Request to create cluster has been sent')
    time.sleep(15) # in order to have some time to update list

    while True:
        cluster = [c for c in magnum.clusters.list() if c.uuid == uuid]
        if len(cluster) != 1:
            raise ValueError('No cluster with such UUID')
        cluster = cluster[0]

        if cluster.status == 'CREATE_FAILED':
            raise ValueError('Something went wrong during cluster creation')
        if cluster.status == 'CREATE_COMPLETE':
            config_cluster(magnum, uuid)
            return uuid

parser = argparse.ArgumentParser(description="Deploy cluster on Openstack.")
parser.add_argument("login", help="lxplus login")
parser.add_argument("password", help="lxplus password")
parser.add_argument('name', help="name of the cluster")
parser.add_argument('keypair', help="keypair")
parser.add_argument('--template', help="cluster template name")
parser.add_argument('--nodes', type=int, help="number of cluster nodes")

args = parser.parse_args()

if __name__ == '__main__':
    magnum = connect(args.login, args.password)

    uuid = create_cluster(magnum, args.name, args.keypair, args.template, args.nodes)
    print('Successfully created a cluster with UUID %s and config files' % uuid)
