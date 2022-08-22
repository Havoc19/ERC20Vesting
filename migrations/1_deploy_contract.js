const Token = artifacts.require("Token");
const Vesting = artifacts.require("Vesting");
module.exports = async function (deployer){
    await deployer.deploy(Token);
    const token = await Token.deployed()

    await deployer.deploy(Vesting,["0xCF32E02F62598d34D395612944baD1eD7746b38D","0xf5F93e7277993f4295e1BAad7216621aAE0F6E3e"],token.address);
}

// # const NftMinter = artifacts.require("NftMinter");
// const NftToken = artifacts.require("NftToken");
// const Pool = artifacts.require("Pool");
// const Token = artifacts.require("Token");

// module.exports = async function(deployer) {
//   await deployer.deploy(Token)
//   const token = await Token.deployed()

//   await deployer.deploy(Pool , token.address)
//   const pool = await Pool.deployed()

//   await token.passMinterRole(pool.address)

//   await deployer.deploy(NftToken , pool.address)
// };