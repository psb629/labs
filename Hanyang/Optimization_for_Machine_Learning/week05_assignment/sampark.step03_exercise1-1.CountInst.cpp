#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdlib.h>

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/IR/DiagnosticHandler.h"
#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/raw_os_ostream.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/Support/raw_ostream.h"

std::string input_path;
llvm::LLVMContext* TheContext;
std::unique_ptr<llvm::Module> TheModule;

void ParseIRSource(void);
void TraverseModule(void);

int main(int argc , char** argv)
{
	if(argc < 2)
	{
		std::cout << "Usage: ./CountInst <ir_file_path>" << std::endl;
		return -1;
	}
	input_path = std::string(argv[1]);

	// Read & Parse IR Source
	ParseIRSource();
	// Traverse TheModule
	TraverseModule();

	return 0;
}

// Read & Parse IR Sources
//  Human-readable assembly(*.ll) or Bitcode(*.bc) format is required
void ParseIRSource(void)
{
	llvm::SMDiagnostic err;

	// Context
	TheContext = new llvm::LLVMContext();
	if( ! TheContext )
	{
		std::cerr << "Failed to allocated llvm::LLVMContext" << std::endl;
		exit( -1 );
	}

	// Module from IR Source
	TheModule = llvm::parseIRFile(input_path, err, *TheContext);
	if( ! TheModule )
	{
		std::cerr << "Failed to parse IR File : " << input_path << std::endl;
		exit( -1 );
	}
}

// Traverse Instructions in TheModule
void TraverseModule(void)
{
	int total_add_inst = 0;
	int total_sub_inst = 0;
	int total_fmul_inst = 0;
	int total_fdiv_inst = 0;

	for( llvm::Module::iterator ModIter = TheModule->begin(); ModIter != TheModule->end(); ++ModIter )
	{
		llvm::Function* Func = llvm::cast<llvm::Function>(ModIter);

		for( llvm::Function::iterator FuncIter = Func->begin(); FuncIter != Func->end(); ++FuncIter )
		{
			llvm::BasicBlock* BB = llvm::cast<llvm::BasicBlock>(FuncIter);
			
			for( llvm::BasicBlock::iterator BBIter = BB->begin(); BBIter != BB->end(); ++BBIter )
			{
				llvm::Instruction* Inst = llvm::cast<llvm::Instruction>(BBIter);

				// if( Inst->isBinaryOp() ) {}
				if( Inst->getOpcode() == llvm::Instruction::Add ) { total_add_inst++; }
				if( Inst->getOpcode() == llvm::Instruction::Sub ) { total_sub_inst++; }
				if( Inst->getOpcode() == llvm::Instruction::FMul ) { total_fmul_inst++; }
				if( Inst->getOpcode() == llvm::Instruction::FDiv ) { total_fdiv_inst++; }
			}
		}
	}

	std::cout << "The Number of ADD Instructions in the Module " << TheModule->getName().str() << " is " << total_add_inst << std::endl;
	std::cout << "The Number of SUB Instructions in the Module " << TheModule->getName().str() << " is " << total_sub_inst << std::endl;
	std::cout << "The Number of FMUL Instructions in the Module " << TheModule->getName().str() << " is " << total_fmul_inst << std::endl;
	std::cout << "The Number of FDIV Instructions in the Module " << TheModule->getName().str() << " is " << total_fdiv_inst << std::endl;
}


