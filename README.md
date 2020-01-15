# SAI deployment scripts

A set of scripts that deploy [sai](http://github.com/makerdao/sai) to an
Ethereum chain of your choosing.

## Description

This repo is composed of two steps:

* Bash [scripts](/scripts) to modify the state of the base system

At the end of the first step, the addresses of deployed contracts are written to
an `out/addresses.json` file. The scripts read those addresses and use `seth`
and `dapp` to modify the deployment, using the values in `out/config.json`.

## Installing

The only way to install everything necessary to deploy is Nix. Run

```
$ nix-shell --pure
```

to drop into a Bash shell with all dependency installed.

### Ethereum node

You'll also need an Ethereum RPC node to connect to. Depending on your usecase, this
could be a local node (e.g. `dapp testnet`) or a remote one.

## Configuration

There are 2 main pieces of configuration necessary for a deployment:

* Ethereum account configuration
* Chain configuration

#### Account configuration

`seth` relies on the presence of environment variables to know which Ethereum account to
use, which RPC server to talk to, etc.

If you're using `nix-shell`, these variables are set automatically for you in
[shell.nix](./shell.nix).

But you can also configure the below variables manually:

- `ETH_FROM`: address of deployment account
- `ETH_PASSWORD`: path of account password file
- `ETH_KEYSTORE`: keystore path
- `ETH_RPC_URL`: URL of the RPC node

### Chain configuration

Some networks have a default config file at `config/<NETWORK>.json`, which will be used if non custom config values are set.
A config file can be passed via param with flag `-f` allowing to execute the script in any network (e.g. `sai-deploy testchain -f <CONFIG_FILE_PATH>`).

Below is the expected structure of such a config file:

```
{
  "description": "",
  "tub_cap": "<Debt ceiling in SAI unit>",
  "tub_mat": "<Liquidation ratio value in percentage (e.g. 150)>",
  "tub_tax": "<Stability fee in percentage per year (e.g. 2.5)>",
  "tub_fee": "<Governance fee in percentage per year (e.g. 2.5)>",
  "tub_axe": "<Liquidation penalty value in percentage (e.g. 12.5)>",
  "tub_gap": "<Spread on `join` and `exit` in percentage (e.g. 3 or -3)>",
  "tap_gap": "<Spread on `boom` and `bust` in percentage (e.g. 3 or -3)>",
  "vox_way": "<Holder fee (interest rate) in percentage (e.g. 2)>",
  "vox_how": "<Time factor accelaration in integer unit (e.g. 1)>",
  "pit": "<Pit address to send MKR to be burnt>",
  "import": {
    "gem": "<Gem token address (if there is an existing one to import)>",
    "gov": "<Gov token address (if there is an existing one to import)>",
    "pip": "<Pip Price feed address (if there is an existing one to import)>",
    "pep": "<Pep Price feed address (if there is an existing one to import)>"
  },
  "pipPrice": "<Initial oracle price (only if pip is not imported)>",
  "pepPrice": "<Initial oracle price (only if pep is not imported)>",
}
```

## Default config files

Currently, there are default config files for 3 networks:

* a local testchain (e.g. `dapp testnet`)
* Kovan
* Mainnet

### Deploy on local testchain with default config file

`sai-deploy testchain`

### Deploy on Kovan with default config file

`sai-deploy kovan`

### Deploy on Mainnet with default config file

`sai-deploy main`

### Deploy on any network passing a custom config file

`sai-deploy <NETWORK> -f <CONFIG_FILE_PATH>`

### Output

Successful deployments save their output to the following files:

- `out/addresses.json`: addresses of all deployed contracts
- `out/config.json`: copy of the configuration file used for the deployment
- `out/abi/`: JSON representation of the ABIs of all deployed contracts
- `out/bin/`: .bin and .bin-runtime files of all deployed contracts
- `out/meta/`: meta.json files of all deployed contracts
- `out/sai-<NETWORK>.log`: output log of deployment

## Nix

To enable full reproducibility of our deployments, we use Nix.

This command will drop you in a shell with all dependencies and environment
variables definend:

```
nix-shell --pure
```

You can even run deploy scripts without having to clone this repo:

```
nix run -f https://github.com/makerdao/sai-deploy-scripts/tarball/master -c sai-deploy testchain
```

Dependencies are managed through a central repository referenced in
[`nix/pkgs.nix`](nix/pkgs.nix) and the main Nix expression to build this
repo is in [`default.nix`](default.nix).

## Smart Contract Dependencies

To update smart contract dependencies use `dapp2nix`:

```sh
nix-shell --pure
dapp2nix help
dapp2nix list
dapp2nix up sai <COMMIT_HASH>
```

To clone smart contract dependencies into working directory run:

```sh
dapp2nix clone-recursive contracts
```

## Additional Documentation

- `sai` [source code](https://github.com/makerdao/sai)

## Latest Mainnet deployment
```
# sai mainnet deployment
# Mon 18 Dec 03:12:57 GMT 2017
# SAI_ADM updated 2019-06-11
export SAI_GEM=0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
export SAI_GOV=0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2
export SAI_PIP=0x729D19f657BD0614b4985Cf1D82531c67569197B
export SAI_PEP=0x99041F808D598B782D5a3e498681C2452A31da08
export SAI_PIT=0x69076e44a9c70a67d5b79d95795aba299083c275
export SAI_ADM=0x9eF05f7F6deB616fd37aC3c959a2dDD25A54E4F5
export SAI_SAI=0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359
export SAI_SIN=0x79f6d0f646706e1261acf0b93dcb864f357d4680
export SAI_SKR=0xf53ad2c6851052a81b42133467480961b2321c09
export SAI_DAD=0x315cbb88168396d12e1a255f9cb935408fe80710
export SAI_MOM=0xf2c5369cffb8ea6284452b0326e326dbfdcb867c
export SAI_VOX=0x9b0f70df76165442ca6092939132bbaea77f2d7a
export SAI_TUB=0x448a5065aebb8e423f0896e6c5d525c040f59af3
export SAI_TAP=0xbda109309f9fafa6dd6a9cb9f1df4085b27ee8ef
export SAI_TOP=0x9b0ccf7c8994e19f39b2b4cf708e0a7df65fa8a3
```
