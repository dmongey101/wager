import {expect} from './chai-setup';
import {ethers} from 'hardhat';
import { ChainlinkAPI } from '../typechain/ChainlinkAPI';
import { Wager } from '../typechain/Wager';

  describe("Wager", function () {
      let chainlinkAPI: ChainlinkAPI;
      let wager: Wager;

      beforeEach(async function () {
        const ChainlinkAPI = await ethers.getContractFactory("ChainlinkAPI");
        chainlinkAPI = <ChainlinkAPI>await ChainlinkAPI.deploy();
    
        const Wager = await ethers.getContractFactory("Wager");
        wager = <Wager>await Wager.deploy(chainlinkAPI.address);
    
      });

      // todo: write more tests
      it("chainlink api should be correct", async function () {
          expect(await wager._chainlinkApi()).to.equal(chainlinkAPI.address);
      })
  })
