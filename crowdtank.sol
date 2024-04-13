// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract crowdtank{
    //struct used to store all project details
    struct Project{
        //contains all the details of the person who wants to raise funds.
        address creator;
        string name;
        string description;
        //uint only stores the positive integers
        uint FundingGoal;
        uint deadline;
        uint amountraised;
        bool projectfunded;
    }
    //used to map the values to each detail of the project
    // unit refers to the project id.
    mapping(uint => Project ) public project;
    // this mapping is used to store each contributors details 
    // first uint is for project id, then address is for the user address and last uint is for the amount of money.
    mapping(uint => mapping( address => uint)) public contributions;
    //this mapping is done to check whether the given id is used 
    mapping(uint => bool) public isIDUsed;
    //event created when some action is done
    event ProjectCreated(uint indexed ProjectId, address indexed creator, string name,string description,uint FundingGoal,uint deadline);
    event ProjectFunded(uint indexed ProjectId, address indexed contributor, uint amount );
    // the withdrawer type is for finding out whether the contributor or the creator is withdrawn
    event Withdrawal(uint indexed ProjectId, address indexed withdrawer, uint amount, string withdrawertype);
    function createProject(string memory _name , string memory _description, uint _fundinggoal, uint _durationSeconds, uint _id) external {
    require(!isIDUsed[_id], "Project Id is already used");
    isIDUsed[_id]=true;
    project[_id]=Project({
        creator: msg.sender,
        name: _name,
        description: _description,
        FundingGoal: _fundinggoal,
        deadline: block.timestamp + _durationSeconds,
        amountraised:0,
        projectfunded: false
        });
    emit ProjectCreated(_id, msg.sender, _name, _description, _fundinggoal,block.timestamp+ _durationSeconds );
    
    
    
}
    function FundProject(uint ProjectId)external payable{
        Project storage project=project[ProjectId]  ;
        // we require the first condition to take place or we send the user the second condition.
        require(block.timestamp<= project.deadline, "Deadline is reached");
        
        require(msg.value>0,"Must send some value of Ether");
        project.amountraised+= msg.value;
        contributions[ProjectId][msg.sender]=msg.value;
        emit ProjectFunded(ProjectId, msg.sender, msg.value);
        if(project.amountraised>= project.FundingGoal){
            project.projectfunded= true;
        }

          }
    function WithDrawFund(uint Id) external payable{
        Project storage project=project[Id];
        require(project.amountraised<= project.FundingGoal, "Full funding reached, User can't withdraw");
        require(block.timestamp<= project.deadline, "Deadline is reached, can't withdraw");
        uint fundsgiven= contributions[Id][msg.sender];
        require(fundsgiven>0,"Must send some value of Ether");
        project.amountraised -= fundsgiven;
        payable(msg.sender).transfer(fundsgiven);   
}
    function AdminWithDrawFunds(uint Id) external payable{
        Project storage project=project[Id];
        uint TotalFundingRaised=project.amountraised;
        require(project.projectfunded, "Project Not funded fully");
        //only creator should be able to call this method
        require( project.creator==msg.sender, "Only Creator can withdraw money");
        require(block.timestamp>= project.deadline, "Deadline not yet reached");
        payable(msg.sender).transfer(TotalFundingRaised);

    }
    


    }

