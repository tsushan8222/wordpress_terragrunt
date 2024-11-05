import sys
import subprocess
import os
import json
import getopt
session = None


def install(package):
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", package, "-q"])


def cfn_exports():
    results = []
    formatted_result = []
    cfn = session.client("cloudformation")
    response = cfn.list_exports()
    while True:
        if "NextToken" in response:
            results.extend(response["Exports"])
            response = cfn.list_exports(NextToken=response["NextToken"])
        else:
            results.extend(response["Exports"])
            break
    for variable in results:
        var = {}
        var['name'] = variable["Name"].replace(
            "-uat-", "").replace("-uat", "").replace("uat-", "")
        var['value'] = variable["Value"]
        var['type'] = 'PLAINTEXT'
        formatted_result.append(var)

    return formatted_result


def write_to_hcl_file(vars, file_name):
    try:
        f = open(file_name, "w")
        content = {}
        content['locals'] = {"common_vars": vars}
        f.write(json.dumps(content))
        f.close()
        return file_name
    except:
        raise RuntimeError("Failed to create variable file")


def usage():
    print("python get_cfn_exports.py -e <env> -r <region> -f <output_file_name> -a <account_no>")


def createBotoSession(env, region, account_no):
    import boto3
    if not env:
        return None
    global session
    roleArn = 'arn:aws:iam::' + \
        account_no + ':role/SuperAdmin'

    # STS connect to specific user
    client = boto3.client('sts', region_name=region)

    assumedRoleObject = client.assume_role(
        RoleArn=roleArn, RoleSessionName='TerragruntSession')
    credentials = assumedRoleObject['Credentials']
    session = boto3.session.Session(
        region_name=region,
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    )
    return session


def main(argv):
    env = None
    region = None
    file = None
    account_no = None
    try:
        opts, args = getopt.getopt(argv, "e:r:f:a:")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-e"):
            env = arg.lower()
        elif opt in ("-r"):
            region = arg.lower()
        elif opt in ("-f"):
            file = arg.lower()
        elif opt in ("-a"):
            account_no = arg.lower()
    createBotoSession(env, region, account_no)
    print(write_to_hcl_file(cfn_exports(), file))


if __name__ == "__main__":
    if sys.version_info < (3, 6):
        raise RuntimeError("A python version 3.6 or newer is required")

    try:
        subprocess.check_output(['python', '-m', 'pip', '--version'])
    except Exception as identifier:
        raise RuntimeError("Pip Version should be correctly installed")
    install("boto3")
    main(sys.argv[1:])
