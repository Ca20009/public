import requests
import json
import split
repos = []
no_auth_repo = ['registry.k8s.io']
auth_v2_providers= ['ghcr.io','public.ecr.aws','docker.io']

#google auth=https://ghcr.io/token?scope=repository:nerdswords/yet-another-cloudwatch-exporter:pull&service=ghcr.io
#working = https://quay.io/v2/auth?scope=repository:sysdig/kspm-collector:pull&service=quay.io
def test1(data):
    for image in data:
        api = 'v2'
        url = (f"https://{image['provider']}/{api}/{image['repo']}/tags/list")
        if image['provider'] in auth_v2_providers:
             auth_url = (f"https://{image['provider']}/token?scope=repository:{image['repo']}:pull&service={image['provider']}")
        else: auth_url = (f"https://{image['provider']}/v2/auth?scope=repository:{image['repo']}:pull&service={image['provider']}")
        if image['provider'] in ['registry.k8s.io','quay.io','ghcr.io','public.ecr.aws','docker.io']:
            print(image)
            print(auth_url)
            if image['provider'] not in no_auth_repo:
                 token=get_auth_token(auth_url)
            else:
                token = "AAA"
            print(auth_url)
            print(token)
            tags=(requests.get(url,headers={ 'Authorization' :f'Bearer {token}'}))
            tags = json.loads(tags.content)
            for t in tags['tags']:
                if t == (image['tag']):
                    image['currentTagDetails'] = t
                    image['latestTagDetails'] = (tags['tags'][0])
    return(data)


def get_auth_token(auth_url):
        auth = (requests.get(auth_url))
        auth = json.loads(auth.content)
        token = (auth['token'])
        return(token)



def strip(repos):
    data=[]
    for image in repos:
        split=(image.split('/')) #split pull string by /
        if len(split) == 2: #adds docker.io (default) to make the rest easier
            split.insert(0,"docker.io")
        tag_split=(split[2].split(':'))#works out the tag
        if len(tag_split) == 3: #dels with iamge sha's
             tag=tag_split[1] + tag_split[2]
        else:
             tag=tag_split[1]
        provider=(split[0]) # provider of the image, amazon, docker.io for example
        repo=(split[1]) + '/' + (tag_split[0])  #the actual repository
        data.append({'full': image, 'tag': tag, 'repo': repo, 'provider' : provider})
    return(data)

data=strip(repos)
data=test1(data)
print(data)
