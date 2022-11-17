import {expect, assert} from './chai-setup';
import {ethers, deployments, getUnnamedAccounts, getNamedAccounts} from 'hardhat';
import {BoilerplateNFT} from '../typechain';
import {setupUser, setupUsers} from './utils';

import {ERC721_NFT_NAME, ERC721_NFT_SYMBOL, ERC721_NFT_TAG, ERC721_BASE_URI_LOCAL} from '../utils/constants';
import { Contract } from '@ethersproject/contracts';

const setup = deployments.createFixture(async () => {
  await deployments.fixture(ERC721_NFT_TAG);
  const {beneficiary} = await getNamedAccounts();
  const contracts = {
    BoilerplateNFT: <BoilerplateNFT>await ethers.getContract(ERC721_NFT_TAG),
  };
  const users = await setupUsers(await getUnnamedAccounts(), contracts);
  return {
    ...contracts,
    users,
    beneficiary: await setupUser(beneficiary, contracts),
  };
});

describe("This is our main Wager testing scope", function () {
    let wager: Contract, signerAddress: any, signer;
    it("should do something with our wager", async function () {
        const Wager = await ethers.getContractFactory("Wager");
        wager = await Wager.deploy("");
        await wager.deployed();
        // get default signer, in Signer abstraction form
        signer = ethers.provider.getSigner(0);

        // get default signer, but just the address!
        [signerAddress] = await ethers.provider.listAccounts();
    })

    it("should set owner to contract deployer", async function () {
        assert.equal(await wager.owner(), signerAddress);
    })
})

describe('BoilerplateNFT Spec', function () {
  // 1. test name
  it('has correct name', async function () {
    const {BoilerplateNFT} = await setup();
    expect(await BoilerplateNFT.name()).to.equal(ERC721_NFT_NAME);
  });

  // 2. test symbol
  it('has correct symbol', async function () {
    const {BoilerplateNFT} = await setup();
    expect(await BoilerplateNFT.symbol()).to.equal(ERC721_NFT_SYMBOL);
  });

  it('total supply is equal to 0 on start', async function () {
    const {BoilerplateNFT} = await setup();
    expect(await BoilerplateNFT.totalSupply()).to.equal(0);
  });
});

describe('BoilerplateNFT Minting', function () {
  it('NFT is mintable', async function () {
    const {beneficiary, BoilerplateNFT} = await setup();
    await beneficiary.BoilerplateNFT.safeMint(beneficiary.address, `${ERC721_BASE_URI_LOCAL}/1`);
    expect((await BoilerplateNFT.balanceOf(beneficiary.address)).toString()).to.equal('1');
    expect(await BoilerplateNFT.tokenURI(0)).to.equal(`${ERC721_BASE_URI_LOCAL}/1`);
  });

  it('NFT is mintable by non owner', async function () {
    const {users, BoilerplateNFT} = await setup();
    await users[0].BoilerplateNFT.safeMint(users[0].address, `${ERC721_BASE_URI_LOCAL}/1`);
    expect((await BoilerplateNFT.balanceOf(users[0].address)).toString()).to.equal('1');
    expect(await BoilerplateNFT.tokenURI(0)).to.equal(`${ERC721_BASE_URI_LOCAL}/1`);
  });
});
