#ifndef _ASTNODE_HPP_
#define _ASTNODE_HPP_

#include<memory>
#include<vector>
#include"location.hh"

using Loc = yy::location;
template<class T>
using UniPtr = std::unique_ptr<T>;
template<class T> 
using UniPtrVec = std::vector<UniPtr<T>>;

class Visitor;
class Node;
class Unit;
class GloDef;
class ValDef;
class ConstDef;
class VarDef;
class FuncDef;

class FParam;
class InitVal;
class Block;

class Expr;

enum class EnumType{
    VOID = 0,
    I32,
    I1,
    FLOAT
};

/**
 * @brief AST的基类
 * AST的节点都继承这个类，其中包含了位置信息
*/
class Node {
private:
    Loc loc_; ///位置信息
    virtual void accept(const Visitor *visitor) = 0;
public:
    Node() = default;
    Node(const Loc &loc): loc_(loc){}
    virtual ~Node(){}

    void setLocation(const Loc &loc){ loc_ = loc; } 
    int getLineNo() const { return loc_.begin.line; }
    int getColumnNo() const { return loc_.begin.column; }
    
};


/**
 * @brief 程序的根节点
 * 其中包含了编译单元列表 
*/
class Unit {
private:
  UniPtrVec<GloDef> glo_defs_;///编译单元
public:
  Unit(const UniPtrVec<GloDef> glo_defs): glo_defs_(glo_defs){}
  virtual void accept(const Visitor *visitor) final;
};


/**
 * @brief 全局变量
 * 全局变量的基类
 */
class GloDef: public Node{};
class ValDef: GloDef{
protected:
  bool is_const_;///是否是常量
  EnumType btype_;///基础类型
  UniPtrVec<Expr> dims_;///各维度
  UniPtr<InitVal> init_val_;///初始值

public:
  ///基本类型
  ValDef(bool is_const, 
          EnumType btype, 
          UniPtr<InitVal> &init_val)
  : is_const_(is_const), btype_(btype), init_val_(std::move(init_val)){}

  ///数组类型
  ValDef(bool is_const,
          EnumType btype, 
          const UniPtrVec<Expr> &dims, 
          UniPtr<InitVal> &init_val)
  : is_const_(is_const), btype_(btype), dims_(dims), init_val_(std::move(init_val)){}

  virtual ~ValDef(){};
};
class ConstDef: public ValDef{
public:
  ConstDef(bool is_const, 
            EnumType btype, 
            UniPtr<InitVal> &init_val)
  : ValDef(is_const, btype, init_val){}

  ConstDef(bool is_const,
          EnumType btype, 
          const UniPtrVec<Expr> &dims, 
          UniPtr<InitVal> &init_val)
  : ValDef(is_const, btype, dims, init_val){}

  virtual void accept(const Visitor *visitor) final;
};
class VarDef: public ValDef{
public:
  VarDef(bool is_const, 
            EnumType btype, 
            UniPtr<InitVal> &init_val)
  : ValDef(is_const, btype, init_val){}

  VarDef(bool is_const,
          EnumType btype, 
          const UniPtrVec<Expr> &dims, 
          UniPtr<InitVal> &init_val)
  : ValDef(is_const, btype, dims, init_val){}

  virtual void accept(const Visitor *visitor) final;
};


class FuncDef: public GloDef{
private:
  EnumType ret_;
  UniPtrVec<FParam> fparams_;
  UniPtr<Block> body_;
public:
  virtual void accept(const Visitor *visitor) final;
};








#endif